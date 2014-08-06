//
//  Game.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

class Game<P: Piece, GL: GameLogic where GL.P == P> {
    let logic: GL
    var currentPlayer = Player.White
    var currentBoard: Board<P>
    
    init(logic: GL) {
        self.logic = logic
        currentBoard = logic.getInitialBoard()
    }
}
