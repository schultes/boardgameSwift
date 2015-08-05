//
//  Piece.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

protocol Piece {
    static func getEmpty() -> Self
    static func getInvalid() -> Self
    var asString: String { get }
}
