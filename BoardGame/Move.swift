//
//  Move.swift
//  BoardGame
//
//  Created by Dominik Schultes on 06.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//


typealias Coords = (x: Int, y: Int)

struct Move<P> {
    typealias Patch = [(coords: Coords, newPiece: P)]
    typealias Steps = [(target: Coords, effects: Patch)]
    
    let source: Coords
    let steps: Steps
    var value: Double?
}
