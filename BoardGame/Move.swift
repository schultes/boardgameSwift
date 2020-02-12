//
//  Move.swift
//  BoardGame
//
//  Created by Dominik Schultes on 06.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//


typealias Coords = (x: Int, y: Int)

struct Move<P> {
    typealias Effect = (coords: Coords, newPiece: P)
    typealias Step = (target: Coords, effects: [Effect])
    
    let source: Coords
    let steps: [Step]
    var value: Double?
}
