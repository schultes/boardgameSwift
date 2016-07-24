//
//  ReversiPiece.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

enum ReversiPiece : String, Piece {
    case Empty = "  "
    case Invalid = "x"
    case White = "◎"
    case Black = "◉"
    
    static func getEmpty() -> ReversiPiece {
        return .Empty
    }
    
    static func getInvalid() -> ReversiPiece {
        return .Invalid
    }
    
    var asString: String {
        return rawValue
    }
    
    func belongsToPlayer(_ player: Player) -> Bool {
        if ((self == ReversiPiece.White) && (player == Player.white)) {return true;}
        if ((self == ReversiPiece.Black) && (player == Player.black)) {return true;}
        return false;
    }
    
    static func getPieceForPlayer(_ player: Player) -> ReversiPiece {
        return player == Player.white ? .White : .Black
    }
}
