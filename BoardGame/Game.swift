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
    func aiSetSearchDepth(depth: Int)
}

class GenericGame<P: Piece, GL: GameLogic where GL.P == P> : Game {
    private let logic: GL
    private let ai: AI<P, GL>
    private var currentPlayer = Player.White
    private var currentBoard: Board<P>
    private var currentMoves: [Move<P>]?
    private var currentStepIndex = 0
    
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
        return logic.getResultOnBoard(currentBoard, forPlayer: currentPlayer)
    }
    
    func getFieldAsStringAt(coords: Coords) -> String {
        return currentBoard[coords.x, coords.y].asString
    }
    
    func getCurrentTargets() -> [Coords] {
        var result = [Coords]()
        if let moves = currentMoves {
            for move in moves {
                let target : Coords = move.steps[currentStepIndex].target
                result.append(target)
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
        if result.finished {return false}

        let (x, y) = coords
        
        if (currentMoves != nil) {
            for move in currentMoves! {
                if x == move.steps[currentStepIndex].target.x && y == move.steps[currentStepIndex].target.y {
                    currentBoard.applyChanges(move.steps[currentStepIndex].effects)
                    
                    if (currentStepIndex+1 == move.steps.count) {
                        currentMoves = nil
                        currentStepIndex = 0
                        currentPlayer = currentPlayer.opponent
                        println(logic.evaluateBoard(currentBoard))
                    } else {
                        var remainingMoves = [Move<P>]()
                        for m in currentMoves! {
                            if x == m.steps[currentStepIndex].target.x && y == m.steps[currentStepIndex].target.y {
                                remainingMoves.append(m)
                            }
                        }
                        currentMoves = remainingMoves
                        currentStepIndex++
                    }
                    
                    return true
                }
            }
        } else {
            var moves = logic.getMovesOnBoard(currentBoard, forPlayer: currentPlayer, forSourceCoords: coords)
            if (moves.isEmpty) {
                if logic.getMovesOnBoard(currentBoard, forPlayer: currentPlayer).isEmpty {
                    // add empty dummy move if there is no real move
                    let dummyMove = Move<P>(coords: (x, y), value: nil)
                    moves.append(dummyMove)
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
        for step in nextMove.steps {
            currentBoard.applyChanges(step.effects)
        }
        println(logic.evaluateBoard(currentBoard))
        currentPlayer = currentPlayer.opponent
        return true
    }
    
    func aiSetSearchDepth(depth: Int) {
        ai.maxSearchDepth = depth
    }
}
