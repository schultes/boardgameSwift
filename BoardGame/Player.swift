//
//  Player.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

enum Player {
    case White, Black
    
    var opponent : Player {
        return self == Player.White ? .Black : .White
    }
}
