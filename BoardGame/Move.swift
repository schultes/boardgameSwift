//
//  Move.swift
//  BoardGame
//
//  Created by Dominik Schultes on 06.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//


typealias Coords = (x: Int, y: Int)

struct Move<P: Piece> {
    typealias Patch = [(coords: Coords, newPiece: P)]
    
    let source: Coords
    let targets: [Coords]
    let effects: Patch
    var value: Double?
}
