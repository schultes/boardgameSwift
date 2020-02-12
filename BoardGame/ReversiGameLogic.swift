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
        let board = Board<P>(empty: P.Empty, invalid: P.Invalid)
        let x = board.columns / 2 - 1
        let y = board.rows / 2 - 1
        board[x, y] = .White;
        board[x, y+1] = .Black;
        board[x+1, y] = .Black;
        board[x+1, y+1] = .White;
        return board
    }
    
    func getMoves(onBoard board: Board<P>, forPlayer player: Player, forSourceCoords sourceCoords: Coords) -> [Move<P>] {
        var result = [Move<P>]()
        let playersPiece = P.getPiece(forPlayer: player)
        if board[sourceCoords.x, sourceCoords.y] == P.Empty {
            let opponent = player.opponent
            var allChanges = [Effect<P>]()
            
            for dx in -1...1 {
                for dy in -1...1 {
                    if dx == 0 && dy == 0 {continue}
                    var tmp = [Effect<P>]()
                    var x = sourceCoords.x + dx
                    var y = sourceCoords.y + dy
                    while board[x, y].belongs(toPlayer: opponent) {
                        let newElement = [(coords: (x, y) as Coords, newPiece: playersPiece)]
                        tmp += newElement
                        
                        x += dx
                        y += dy
                    }
                    if (tmp.isEmpty) {continue}
                    if (board[x, y].belongs(toPlayer: player)) {
                        allChanges += tmp
                    }
                }
            }

            if (!allChanges.isEmpty) {
                let newElement = [(coords: sourceCoords, newPiece: playersPiece)]
                allChanges += newElement
                let move = Move<P>(source: sourceCoords, steps: [(target: sourceCoords, effects: allChanges)], value: nil)
                result.append(move)
            }
        }
        return result
    }
    
    func getMoves(onBoard board: Board<P>, forPlayer player: Player) -> [Move<P>] {
        var result = [Move<P>]()
        for x in 0..<board.columns {
            for y in 0..<board.rows {
                result += getMoves(onBoard: board, forPlayer: player, forSourceCoords: (x, y))
            }
        }
        return result
    }
    
    func evaluateBoard(_ board: Board<P>) -> Double {
        var result = 0.0
        for x in 0..<board.columns {
            for y in 0..<board.rows {
                if (board[x, y].belongs(toPlayer: .white)) {result += 1}
                if (board[x, y].belongs(toPlayer: .black)) {result -= 1}
            }
        }
        return result
    }
    
    func getResult(onBoard board: Board<P>, forPlayer _: Player) -> (finished: Bool, winner: Player?) {
        var finished = true
        var winner: Player?
        let movesOfBothPlayers = [getMoves(onBoard: board, forPlayer: Player.white), getMoves(onBoard: board, forPlayer: Player.black)]
        for movesOfOnePlayer in movesOfBothPlayers {
            if !movesOfOnePlayer.isEmpty {finished = false}
        }
        if (finished) {
            if (evaluateBoard(board) > 0) {winner = .white}
            if (evaluateBoard(board) < 0) {winner = .black}
        }
        return (finished, winner)
    }
}
