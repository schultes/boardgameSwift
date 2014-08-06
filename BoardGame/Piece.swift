//
//  Piece.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

protocol Piece {
    class func getEmpty() -> Self
    class func getInvalid() -> Self
}
