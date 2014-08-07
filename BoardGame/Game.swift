//
//  Game.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

protocol Game {
    var isCurrentPlayerWhite: Bool { get }
    var result: (finished: Bool, winner: Player?) { get }
    func getFieldAsStringAt(coords: Coords) -> String
    func getCurrentTargets() -> [Coords]
    func restart()
    func userActionAt(coords: Coords) -> Bool
    func aiMove() -> Bool
}

class GenericGame<P: Piece, GL: GameLogic where GL.P == P> : Game {
    private let logic: GL
    private let ai: AI<P, GL>
    private var currentPlayer = Player.White
    private var currentBoard: Board<P>
    private var currentMoves: [Move<P>]?
    
    init(logic: GL) {
        self.logic = logic
        self.ai = AI<P, GL>(logic: logic)
        currentBoard = logic.getInitialBoard()
    }
    
    /* a read-only computed property */
    var isCurrentPlayerWhite: Bool {
        return currentPlayer == Player.White
    }
    
    /* a read-only computed property */
    var result: (finished: Bool, winner: Player?) {
        return logic.getResult(currentBoard)
    }
    
    func getFieldAsStringAt(coords: Coords) -> String {
        return currentBoard[coords.x, coords.y].asString
    }
    
    func getCurrentTargets() -> [Coords] {
        var result = [Coords]()
        if let moves = currentMoves {
            for move in moves {
                // TODO: support multiple targets
                result += move.targets[0]
            }
        }
        return result
    }
    
    func restart() {
        currentPlayer = Player.White
        currentBoard = logic.getInitialBoard()
        currentMoves = nil
    }
    
    /* Returns true iff something at the model has changed. */
    func userActionAt(coords: Coords) -> Bool {
        if !isCurrentPlayerWhite {return false}
        if result.finished {return false}

        let (x, y) = coords
        
        if currentMoves {
            for move in currentMoves! {
                // TODO: work with multiple targets
                if x == move.targets[0].x && y == move.targets[0].y {
                    currentMoves = nil
                    
                    currentBoard.applyChanges(move.effects)
                    currentPlayer = currentPlayer.opponent()
                    println(logic.evaluateBoard(currentBoard))
                    
                    return true
                }
            }
        } else {
            var moves = logic.getMovesOnBoard(currentBoard, forPlayer: currentPlayer, forSourceCoords: coords)
            if (moves.isEmpty) {
                if GameLogicHelper.getAllMovesOnBoard(currentBoard, withLogic: logic, forPlayer: currentPlayer).isEmpty {
                    // add empty dummy move if there is no real move
                    let dummyMove = Move<P>(source: (x, y), targets: [(x, y)], effects: Move<P>.Patch(), value: nil)
                    moves += dummyMove
                }
            }
            if (!moves.isEmpty) {
                currentMoves = moves
                return true
            }
        }
        return false
    }
    
    /* Returns true iff something at the model has changed. */
    func aiMove() -> Bool {
        if result.finished {return false}
        let nextMove = ai.getNextMoveOnBoard(currentBoard, forPlayer: currentPlayer)
        currentBoard.applyChanges(nextMove.effects)
        println(logic.evaluateBoard(currentBoard))
        currentPlayer = currentPlayer.opponent()
        return true
    }
    
}
