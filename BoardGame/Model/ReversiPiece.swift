//
//  ReversiPiece.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

enum ReversiPiece : String, CustomStringConvertible {
    case Empty = "  "
    case Invalid = "x"
    case White = "◎"
    case Black = "◉"
    
    var description: String {
        return rawValue
    }
    
    func belongs(toPlayer player: Player) -> Bool {
        if ((self == ReversiPiece.White) && (player == Player.white)) {return true;}
        if ((self == ReversiPiece.Black) && (player == Player.black)) {return true;}
        return false;
    }
    
    static func getPiece(forPlayer player: Player) -> ReversiPiece {
        return player == Player.white ? .White : .Black
    }
}
