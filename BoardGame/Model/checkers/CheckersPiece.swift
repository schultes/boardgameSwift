//
//  CheckersPiece.swift
//  BoardGame
//
//  Created by Dominik Schultes on 05.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

enum CheckersPiece : String, CustomStringConvertible {
    case Empty = "  "
    case Invalid = "x"
    case WhiteMan = "◎"
    case BlackMan = "◉"
    case WhiteKing = "♕"
    case BlackKing = "♛"
    
    var description: String {
        return rawValue
    }
    
    func belongs(toPlayer player: Player) -> Bool {
        if ((self == CheckersPiece.WhiteMan) || (self == CheckersPiece.WhiteKing)) && (player == Player.white) {return true}
        if ((self == CheckersPiece.BlackMan) || (self == CheckersPiece.BlackKing)) && (player == Player.black) {return true}
        return false;
    }
    
    static func getMan(forPlayer player: Player) -> CheckersPiece {
        return player == Player.white ? .WhiteMan : .BlackMan
    }
    
    static func getKing(forPlayer player: Player) -> CheckersPiece {
        return player == Player.white ? .WhiteKing : .BlackKing
    }
}
