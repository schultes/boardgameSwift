//
//  ReversiGameLogic.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

class ReversiGameLogic : GameLogic {
    
    typealias P = ReversiPiece
    
    func getInitialBoard() -> Board<P> {
        var board = Board<P>()
        let x = board.columns / 2 - 1
        let y = board.rows / 2 - 1
        board[x, y] = .White;
        board[x, y+1] = .Black;
        board[x+1, y] = .Black;
        board[x+1, y+1] = .White;
        return board
    }
    
    func getTargetFieldsOnBoard(board: Board<P>, forPlayer player: Player, forSourceX x: Int, andSourceY y: Int) -> Array<((Int, Int), Array<((Int, Int), P)>)> {
        var result = Array<((Int, Int), Array<((Int, Int), P)>)>()
        if board[x, y] == P.Empty {
            let directions = [(0,1),(0,-1),(1,0),(-1,0),(1,1),(-1,-1),(1,-1),(-1,1)]
            let opponent = player.opponent()
            var allChanges = Array<((Int, Int), P)>()
            for d in directions {
                var tmp = Array<((Int, Int), P)>()
                var i = 1
                var coords = (x+i*d.0, y+i*d.1)
                while (board[coords.0, coords.1].belongsToPlayer(opponent)) {
                    let newPiece = P.getPieceForPlayer(player)
                    let newElement = (coords, newPiece)
                    tmp += newElement
                    i++;
                    coords = (x+i*d.0, y+i*d.1)
                }
                if (tmp.isEmpty) {continue;}
                if (board[coords.0, coords.1].belongsToPlayer(player)) {
                    allChanges += tmp
                }
            }
            if (!allChanges.isEmpty) {
                let newElement = ((x, y), P.getPieceForPlayer(player))
                allChanges += newElement
                result += ((x, y), allChanges)
            }
        }
        return result
    }
    
    func evaluateBoard(board: Board<P>) -> Double {
        var result = 0.0
        for x in 0..<board.columns {
            for y in 0..<board.rows {
                if (board[x, y].belongsToPlayer(.White)) {result += 1}
                if (board[x, y].belongsToPlayer(.Black)) {result -= 1}
            }
        }
        return result
    }
    
    func getResult(board: Board<P>) -> (finished: Bool, winner: Player?) {
        var finished = true
        var winner: Player?
        let movesOfBothPlayers = [GameLogicHelper.getAllMovesOnBoard(board, logic: self, forPlayer: Player.White), GameLogicHelper.getAllMovesOnBoard(board, logic: self, forPlayer: Player.Black)]
        for movesOfOnePlayer in movesOfBothPlayers {
            if !movesOfOnePlayer.isEmpty {finished = false}
        }
        if (finished) {
            if (evaluateBoard(board) > 0) {winner = .White}
            if (evaluateBoard(board) < 0) {winner = .Black}
        }
        return (finished, winner)
    }
}
