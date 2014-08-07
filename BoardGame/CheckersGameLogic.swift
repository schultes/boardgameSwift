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
        let opponentsMan = P.getManForPlayer(player.opponent())
        let opponentsKing = P.getKingForPlayer(player.opponent())
        let forwardDirection = player == Player.White ? -1 : 1
        
        // man's move
        if board[sc.x, sc.y] == playersMan {
            for dx in [-1, 1] {
                let tx = sc.x + dx
                let ty = sc.y + forwardDirection
                let tc: Coords = (tx, ty)
                if board[tx, ty] == P.Empty {
                    result += Move<P>(source: sc, targets: [tc], effects: [(sc, P.Empty), (tc, playersMan)], value: nil)
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