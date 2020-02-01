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
    
    init(source: Coords, steps: Steps, value: Double?) {
        self.source = source
        self.steps = steps
        self.value = value
    }
    
    init(coords: Coords, value: Double?) {
        // creates empty dummy move
        source = coords
        steps = [(target: coords, effects: Patch())]
        self.value = value
    }
}
