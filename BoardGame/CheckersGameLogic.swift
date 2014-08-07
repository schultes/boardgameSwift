//
//  CheckersGameLogic.swift
//  BoardGame
//
//  Created by Dominik Schultes on 05.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

class CheckersGameLogic : GameLogic {
    
    typealias P = CheckersPiece
    
    func getInitialBoard() -> Board<P> {
        var board = Board<P>()
        for x in 0..<board.columns {
            for y in 0..<3 {
                if (x+y) % 2 == 1 {
                    board[x, y] = .BlackMan
                }
            }
            for y in board.rows-3..<board.rows {
                if (x+y) % 2 == 1 {
                    board[x, y] = .WhiteMan
                }
            }
        }
        return board
    }
    
    func getMovesOnBoard(board: Board<P>, forPlayer player: Player, forSourceCoords sc: Coords) -> [Move<P>] {
        var result = [Move<P>]()
        let playersMan = P.getManForPlayer(player)
        let playersKing = P.getKingForPlayer(player)
        let forwardDirection = player == Player.White ? -1 : 1
        
        // man's move
        if board[sc.x, sc.y] == playersMan {
            for dx in [-1, 1] {
                let tx = sc.x + dx
                let ty = sc.y + forwardDirection
                let tc: Coords = (tx, ty)
                // normal step
                if board[tx, ty] == P.Empty {
                    result += Move<P>(source: sc, steps: [(target: tc, effects: [(sc, P.Empty), (tc, playersMan)])], value: nil)
                }
            }
            
            // capture
            let arrayOfSteps = recursiveCaptureOnBoard(board, forPlayer: player, forCurrentCoords: sc)
            for steps in arrayOfSteps {
                result += Move<P>(source: sc, steps: steps, value: nil)
            }
        }
        
        return result
    }
    
    func recursiveCaptureOnBoard(board: Board<P>, forPlayer player: Player, forCurrentCoords cc: Coords) -> [Move<P>.Steps] {
        var result = Array<Move<P>.Steps>()
        let forwardDirection = player == Player.White ? -1 : 1
        
        for dx in [-1, 1] {
            let tx = cc.x + dx
            let ty = cc.y + forwardDirection
            let tc: Coords = (tx, ty)
            if board[tx, ty].belongsToPlayer(player.opponent) {
                let t2x = tx + dx
                let t2y = ty + forwardDirection
                let t2c: Coords = (t2x, t2y)
                if board[t2x, t2y] == P.Empty {
                    let effects : Move<P>.Patch = [(cc, P.Empty), (tc, P.Empty), (t2c, P.getManForPlayer(player))]
                    let thisSteps = [(target: t2c, effects: effects)]
                    var newBoard = Board<P>()
                    board.copyToBoard(newBoard)
                    newBoard.applyChanges(effects)
                    
                    let arrayOfSubsequentSteps = recursiveCaptureOnBoard(newBoard, forPlayer: player, forCurrentCoords: t2c)
                    if arrayOfSubsequentSteps.isEmpty {
                        result.append(thisSteps)
                    } else {
                        for subsequentSteps in arrayOfSubsequentSteps {
                            let concatenatedSteps = thisSteps + subsequentSteps
                            result += concatenatedSteps
                        }
                    }
                }
            }
        }
        return result
    }
    
    func evaluateBoard(board: Board<P>) -> Double {
        return 0.0
    }
    
    func getResult(board: Board<P>) -> (finished: Bool, winner: Player?) {
        return (false, nil)
    }
}