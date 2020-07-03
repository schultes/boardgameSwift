#if false
let Ꮻpackage = "de.thm.mow.boardgame.model"
let Ꮻimports = ["de.thm.mow.boardgame.model.support.*"]
#endif

class Board<P> {
    let columns = 8
    let rows = 8
    var pieces: [P]
    let invalid: P
    init(empty: P, invalid: P) {
        pieces = [P](repeating: empty, count: columns * rows)
        self.invalid = invalid
    }

    init(board: Board<P>) {
        pieces = board.pieces.copy()
        invalid = board.invalid
    }

    private func indexIsValidFor(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }

    private func indexFor(row: Int, column: Int) -> Int {
        return (row * columns) + column
    }

    subscript(column: Int, row: Int) -> P {
        get {
            if (!indexIsValidFor(row: row, column: column)) {
                return invalid
            }

            return pieces[indexFor(row: row, column: column)]
        }

        set {
            assert(indexIsValidFor(row: row, column: column), "Index out of range")
            pieces[indexFor(row: row, column: column)] = newValue
        }
    }

    func applyChanges(_ changes: [Effect<P>]) {
        for change in changes {
            self[change.coords.x, change.coords.y] = change.newPiece
        }
    }
}
