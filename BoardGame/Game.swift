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
    func getFieldAsString(atCoords coords: Coords) -> String
    func getCurrentTargets() -> [Coords]
    func restart()
    func userAction(atCoords coords: Coords) -> Bool
    func aiMove() -> Bool
    func aiSetSearchDepth(_ depth: Int)
}

class GenericGame<GL: GameLogic> : Game {
    typealias P = GL.P
    
    private let logic: GL
    private let ai: AI<GL>
    private var currentPlayer = Player.white
    private var currentBoard: Board<P>
    private var currentMoves: [Move<P>]?
    private var currentStepIndex = 0
    
    init(logic: GL) {
        self.logic = logic
        self.ai = AI<GL>(logic: logic)
        currentBoard = logic.getInitialBoard()
    }
    
    /* a read-only computed property */
    var isCurrentPlayerWhite: Bool {
        return currentPlayer == Player.white
    }
    
    /* a read-only computed property */
    var result: (finished: Bool, winner: Player?) {
        return logic.getResult(onBoard: currentBoard, forPlayer: currentPlayer)
    }
    
    func getFieldAsString(atCoords coords: Coords) -> String {
        return String(describing: currentBoard[coords.x, coords.y])
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
        currentPlayer = Player.white
        currentBoard = logic.getInitialBoard()
        currentMoves = nil
    }
    
    /* Returns true iff something at the model has changed. */
    func userAction(atCoords coords: Coords) -> Bool {
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
                        print(logic.evaluateBoard(currentBoard))
                    } else {
                        var remainingMoves = [Move<P>]()
                        for m in currentMoves! {
                            if x == m.steps[currentStepIndex].target.x && y == m.steps[currentStepIndex].target.y {
                                remainingMoves.append(m)
                            }
                        }
                        currentMoves = remainingMoves
                        currentStepIndex += 1
                    }
                    
                    return true
                }
            }
        } else {
            var moves = logic.getMoves(onBoard: currentBoard, forPlayer: currentPlayer, forSourceCoords: coords)
            if (moves.isEmpty) {
                if logic.getMoves(onBoard: currentBoard, forPlayer: currentPlayer).isEmpty {
                    // add empty dummy move if there is no real move
                    let dummyMove = Move<P>(
                        source: (x, y),
                        steps: [(target: (x, y), effects: Move<P>.Patch())],
                        value: nil)
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
        let nextMove = ai.getNextMove(onBoard: currentBoard, forPlayer: currentPlayer)
        for step in nextMove.steps {
            currentBoard.applyChanges(step.effects)
        }
        print(logic.evaluateBoard(currentBoard))
        currentPlayer = currentPlayer.opponent
        return true
    }
    
    func aiSetSearchDepth(_ depth: Int) {
        ai.maxSearchDepth = depth
    }
}
