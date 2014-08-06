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
    
    func belongsToPlayer(player: Player) -> Bool {
        if ((self == ReversiPiece.White) && (player == Player.White)) {return true;}
        if ((self == ReversiPiece.Black) && (player == Player.Black)) {return true;}
        return false;
    }
    
    static func getPieceForPlayer(player: Player) -> ReversiPiece {
        return player == .White ? .White : .Black
    }
}