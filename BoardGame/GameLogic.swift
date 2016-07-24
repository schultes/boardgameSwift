//
//  GameLogic.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

protocol GameLogic {
    associatedtype P: Piece
    
    func getInitialBoard() -> Board<P>
    func getMovesOnBoard(_ board: Board<P>, forPlayer: Player, forSourceCoords: Coords) -> [Move<P>]
    func getMovesOnBoard(_ board: Board<P>, forPlayer player: Player) -> [Move<P>]
    func evaluateBoard(_ board: Board<P>) -> Double
    func getResultOnBoard(_ board: Board<P>, forPlayer: Player) -> (finished: Bool, winner: Player?)
}
