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
        
        let allMoves = getMovesOnBoard(board, forPlayer: player)
        for move in allMoves {
            if move.source.x == sc.x && move.source.y == sc.y {
                result.append(move)
            }
        }
        
        return result
    }
    
    func getMovesOnBoard(board: Board<P>, forPlayer player: Player) -> [Move<P>] {
        return getMovesOnBoard(board, forPlayer: player, ignoreCaptureObligation: false)
    }
    
    private func getMovesOnBoard(board: Board<P>, forPlayer player: Player, ignoreCaptureObligation: Bool) -> [Move<P>] {
        var normalMoves = [Move<P>]()
        var captureMoves = [Move<P>]()
        let forwardDirection = player == Player.White ? -1 : 1
        
        for x in 0..<board.columns {
            for y in 0..<board.rows {
                let sc : Coords = (x, y)
                let sourcePiece = board[sc.x, sc.y]
                if sourcePiece.belongsToPlayer(player) {
                    let sourcePieceIsMan = (sourcePiece == P.getManForPlayer(player))
                    let range = sourcePieceIsMan ? 1...1 : 1..<board.rows
                    let yDirections = sourcePieceIsMan ? [forwardDirection] : [-1, 1]
                    
                    // normal step
                    for dy in yDirections {
                        for dx in [-1, 1] {
                            for i in range {
                                let tx = sc.x + i*dx
                                let ty = sc.y + i*dy
                                let tc: Coords = (tx, ty)
                                if board[tx, ty] != P.Empty {break}
                                let targetPiece = getTargetPieceOnBoard(board, forPlayer: player, atCoords: tc, forSourcePiece: sourcePiece)
                                normalMoves.append(Move<P>(source: sc, steps: [(target: tc, effects: [(sc, P.Empty), (tc, targetPiece)])], value: nil))
                            }
                        }
                    }
                    
                    // capture
                    let arrayOfSteps = recursiveCaptureOnBoard(board, forPlayer: player, forCurrentCoords: sc, withRange: range, inYdirections: yDirections)
                    for steps in arrayOfSteps {
                        captureMoves.append(Move<P>(source: sc, steps: steps, value: nil))
                    }
                    
                }
            }
        }
        if (ignoreCaptureObligation) {
            return captureMoves + normalMoves
        }
        return !captureMoves.isEmpty ? captureMoves : normalMoves
    }
    
    private func recursiveCaptureOnBoard(board: Board<P>, forPlayer player: Player, forCurrentCoords cc: Coords, withRange range: Range<Int>, inYdirections yDirections: [Int]) -> [Move<P>.Steps] {
        var result = Array<Move<P>.Steps>()
        
        for dy in yDirections {
            for dx in [-1, 1] {
                for i in range {
                    let tx = cc.x + i*dx
                    let ty = cc.y + i*dy
                    let tc: Coords = (tx, ty)
                    if board[tx, ty].belongsToPlayer(player.opponent) {
                        let t2x = tx + dx
                        let t2y = ty + dy
                        let t2c: Coords = (t2x, t2y)
                        if board[t2x, t2y] == P.Empty {
                            let sourcePiece = board[cc.x, cc.y]
                            let targetPiece = getTargetPieceOnBoard(board, forPlayer: player, atCoords: t2c, forSourcePiece: sourcePiece)
                            let effects : Move<P>.Patch = [(cc, P.Empty), (tc, P.Empty), (t2c, targetPiece)]
                            let thisSteps = [(target: t2c, effects: effects)]
                            if sourcePiece != targetPiece {
                                // promotion took place (man -> king): stop recursion!
                                result.append(thisSteps)
                            } else {
                                var newBoard = Board<P>()
                                board.copyToBoard(newBoard)
                                newBoard.applyChanges(effects)
                                
                                let arrayOfSubsequentSteps = recursiveCaptureOnBoard(newBoard, forPlayer: player, forCurrentCoords: t2c, withRange: range, inYdirections: yDirections)
                                if arrayOfSubsequentSteps.isEmpty {
                                    result.append(thisSteps)
                                } else {
                                    for subsequentSteps in arrayOfSubsequentSteps {
                                        let concatenatedSteps = thisSteps + subsequentSteps
                                        result.append(concatenatedSteps)
                                    }
                                }
                            }
                        }
                        break
                    }
                }
            }
        }
        return result
    }
    
    private func getTargetPieceOnBoard(board: Board<P>, forPlayer player: Player, atCoords coords: Coords, forSourcePiece sourcePiece: P) -> P {
        let finalRow = player == Player.White ? 0 : board.rows-1
        if (coords.y == finalRow) {return P.getKingForPlayer(player)}
        return sourcePiece
    }
    
    func evaluateBoard(board: Board<P>) -> Double {
        var result = 0.0
        
        // remaining pieces
        for x in 0..<board.columns {
            for y in 0..<board.rows {
                if (board[x, y].belongsToPlayer(.White)) {result += 1}
                if (board[x, y] == P.WhiteKing) {result += 3}
                
                if (board[x, y].belongsToPlayer(.Black)) {result -= 1}
                if (board[x, y] == P.BlackKing) {result -= 3}
            }
        }
        
        // mobility
        let whiteMoves = getMovesOnBoard(board, forPlayer: .White, ignoreCaptureObligation: true)
        let blackMoves = getMovesOnBoard(board, forPlayer: .Black, ignoreCaptureObligation: true)
        result += Double(whiteMoves.count)
        result -= Double(blackMoves.count)
        
        return result
    }
    
    func getResultOnBoard(board: Board<P>, forPlayer player: Player) -> (finished: Bool, winner: Player?) {
        let movesOfCurrentPlayer = getMovesOnBoard(board, forPlayer: player)
        if movesOfCurrentPlayer.isEmpty {return (true, player.opponent)}
        return (false, nil)
    }
}