//
//  Board.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

class Board<P: Piece> {
    let columns = 8
    let rows = 8
    var pieces: [P]
    
    init() {
        pieces = [P](count: columns*rows, repeatedValue: P.getEmpty())
    }
    
    private func indexIsValidForRow(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    private func indexForRow(row: Int, column: Int) -> Int {
        return (row * columns) + column
    }
    
    subscript(column: Int, row: Int) -> P {
        get {
            if (!indexIsValidForRow(row, column: column)) {return P.getInvalid()}
            return pieces[indexForRow(row, column: column)]
        }
        set {
            assert(indexIsValidForRow(row, column: column), "Index out of range")
            pieces[indexForRow(row, column: column)] = newValue
        }
    }
    
    func applyChanges(changes: Array<((Int, Int), P)>) {
        for change in changes {
            self[change.0.0, change.0.1] = change.1
        }
    }
    
    func copyToBoard(copy: Board<P>) {
        assert(columns == copy.columns && rows == copy.rows)
        copy.pieces = pieces
    }

}
