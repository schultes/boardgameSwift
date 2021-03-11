#if false
let Ꮻpackage = "de.thm.mow.boardgame.model"
let Ꮻimports = ["de.thm.mow.boardgame.model.support.*"]
#endif

class Board<P> {
    let invalid: P
    var pieces: [P]
    init(invalid: P, pieces: [P]) {
        self.invalid = invalid
        self.pieces = pieces
    }

    let columns = 8
    let rows = 8
    convenience init(empty: P, invalid: P) {
        self.init(invalid: invalid, pieces: [P](repeating: empty, count: 64))
    }

    func clone() -> Board<P> {
        return Board<P>(invalid: invalid, pieces: pieces.copy())
    }

    func changedCopy(changes: [Effect<P>]) -> Board<P> {
        let copiedBoard = clone()
        copiedBoard.applyChanges(changes)
        return copiedBoard
    }

    func changedCopy(move: Move<P>) -> Board<P> {
        let copiedBoard = clone()
        copiedBoard.applyChanges(move: move)
        return copiedBoard
    }

    private func indexIsValidFor(row: Int, column: Int) -> Bool {
        return row >= 0 && row < rows && column >= 0 && column < columns
    }

    private func indexFor(row: Int, column: Int) -> Int {
        return (row * columns) + column
    }

    subscript(coords: Coords) -> P {
        get {
            return self[coords.x, coords.y]
        }

        set {
            self[coords.x, coords.y] = newValue
        }
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

    func applyChanges(move: Move<P>) {
        move.steps.forEach {
            applyChanges($0.effects)
        }
    }

    func applyChanges(_ changes: [Effect<P>]) {
        for change in changes {
            self[change.coords] = change.newPiece
        }
    }
}
