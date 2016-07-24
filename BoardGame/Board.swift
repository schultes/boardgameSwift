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
        pieces = [P](repeating: P.getEmpty(), count: columns*rows)
    }
    
    private func indexIsValidForRow(_ row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }
    
    private func indexForRow(_ row: Int, column: Int) -> Int {
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
    
    func applyChanges(_ changes: Move<P>.Patch) {
        for change in changes {
            self[change.coords.x, change.coords.y] = change.newPiece
        }
    }
    
    func copyToBoard(_ copy: Board<P>) {
        assert(columns == copy.columns && rows == copy.rows)
        copy.pieces = pieces
    }

}
