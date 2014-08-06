//
//  GameLogic.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

protocol GameLogic {
    typealias P: Piece
    
    func getInitialBoard() -> Board<P>
    func getMovesOnBoard(board: Board<P>, forPlayer: Player, forSourceCoords: Coords) -> [Move<P>]
    func evaluateBoard(board: Board<P>) -> Double
    func getResult(board: Board<P>) -> (finished: Bool, winner: Player?)
}


class GameLogicHelper<P: Piece, GL: GameLogic where GL.P == P> {
    class func getAllMovesOnBoard(board: Board<P>, withLogic logic: GL, forPlayer player: Player) -> [Move<P>] {
        var result = [Move<P>]()
        for x in 0..<board.columns {
            for y in 0..<board.rows {
                result += logic.getMovesOnBoard(board, forPlayer: player, forSourceCoords: (x, y))
            }
        }
        return result
    }
}