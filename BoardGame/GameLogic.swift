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
    func getTargetFieldsOnBoard(board: Board<P>, forPlayer: Player, forSourceX: Int, andSourceY: Int) -> Array<((Int, Int), Array<((Int, Int), P)>)>
    func evaluateBoard(board: Board<P>) -> Double
    func getResult(board: Board<P>) -> (finished: Bool, winner: Player?)
}


class GameLogicHelper<P: Piece, GL: GameLogic where GL.P == P> {
    class func getAllMovesOnBoard(board: Board<P>, logic: GL, forPlayer player: Player) -> Array<((Int, Int), ((Int, Int), Array<((Int, Int), P)>))> {
        var result = Array<((Int, Int), ((Int, Int), Array<((Int, Int), P)>))>()
        for x in 0..<board.columns {
            for y in 0..<board.rows {
                let targets = logic.getTargetFieldsOnBoard(board, forPlayer: player, forSourceX: x, andSourceY: y)
                for target in targets {
                    result += ((x, y), target)
                }
            }
        }
        return result
    }
}