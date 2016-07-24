//
//  CheckersPiece.swift
//  BoardGame
//
//  Created by Dominik Schultes on 05.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

enum CheckersPiece : String, Piece {
    case Empty = "  "
    case Invalid = "x"
    case WhiteMan = "◎"
    case BlackMan = "◉"
    case WhiteKing = "♕"
    case BlackKing = "♛"
    
    static func getEmpty() -> CheckersPiece {
        return .Empty
    }
    
    static func getInvalid() -> CheckersPiece {
        return .Invalid
    }
    
    var asString: String {
        return rawValue
    }
    
    func belongsToPlayer(_ player: Player) -> Bool {
        if ((self == CheckersPiece.WhiteMan) || (self == CheckersPiece.WhiteKing)) && (player == Player.white) {return true}
        if ((self == CheckersPiece.BlackMan) || (self == CheckersPiece.BlackKing)) && (player == Player.black) {return true}
        return false;
    }
    
    static func getManForPlayer(_ player: Player) -> CheckersPiece {
        return player == Player.white ? .WhiteMan : .BlackMan
    }
    
    static func getKingForPlayer(_ player: Player) -> CheckersPiece {
        return player == Player.white ? .WhiteKing : .BlackKing
    }
}
