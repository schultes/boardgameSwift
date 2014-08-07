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
        return toRaw()
    }
    
    static func getManForPlayer(player: Player) -> CheckersPiece {
        return player == Player.White ? .WhiteMan : .BlackMan
    }
    
    static func getKingForPlayer(player: Player) -> CheckersPiece {
        return player == Player.White ? .WhiteKing : .BlackKing
    }
}
