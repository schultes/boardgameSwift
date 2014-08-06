//
//  Player.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

enum Player {
    case White, Black
    
    func opponent() -> Player {
        if self == .White {return .Black} else {return .White}
    }
}
