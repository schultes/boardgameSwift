#if false
let Ꮻpackage = "de.thm.mow.boardgame.model.chess"
let Ꮻimports = ["de.thm.mow.boardgame.model.*", "de.thm.mow.boardgame.model.support.*"]
#endif

class ChessBoard: Board<ChessPiece> {
    var evaluation: Double
    var whiteKing: Coords
    var blackKing: Coords
    init(pieces: [ChessPiece], evaluation: Double = 0.0, whiteKing: Coords = (x: 4, y: 7), blackKing: Coords = (x: 4, y: 0)) {
        self.evaluation = evaluation
        self.whiteKing = whiteKing
        self.blackKing = blackKing
        super.init(invalid: ChessPiece.Invalid, pieces: pieces)
    }

    convenience init() {
        self.init(pieces: [ChessPiece](repeating: ChessPiece.Empty, count: 64))
    }

    override func clone() -> Board<ChessPiece> {
        return ChessBoard(pieces: pieces.copy(), evaluation: evaluation, whiteKing: whiteKing, blackKing: blackKing)
    }

    override func applyChanges(_ changes: [Effect<ChessPiece>]) {
        let lastChange = changes.last!
        let p = lastChange.newPiece.player!
        let oldPiece = self[lastChange.coords]
        if oldPiece.belongs(toPlayer: p.opponent) {
            evaluation -= oldPiece.value
        }

        if lastChange.newPiece == ChessPiece.queen(ofPlayer: p) && self[changes.first!.coords] == ChessPiece.pawn(ofPlayer: p) {
            evaluation += ChessPiece.queen(ofPlayer: p).value - ChessPiece.pawn(ofPlayer: p).value // promotion
        }

        if lastChange.newPiece == ChessPiece.king(ofPlayer: p) {
            if p == Player.white {
                whiteKing = lastChange.coords
            } else {
                blackKing = lastChange.coords
            }
        }

        super.applyChanges(changes)
    }
}
