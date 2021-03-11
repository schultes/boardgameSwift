#if false
let Ꮻpackage = "de.thm.mow.boardgame.model.chess"
let Ꮻimports = ["de.thm.mow.boardgame.model.*", "de.thm.mow.boardgame.model.support.*"]
#endif

class ChessBoard: Board<ChessPiece> {
    var evaluation: Double
    var whiteKing: Coords
    var blackKing: Coords
    var twoStepsPawn: Coords?
    init(pieces: [ChessPiece], evaluation: Double = 0.0, whiteKing: Coords = (x: 4, y: 7), blackKing: Coords = (x: 4, y: 0), twoStepsPawn: Coords? = nil) {
        self.evaluation = evaluation
        self.whiteKing = whiteKing
        self.blackKing = blackKing
        self.twoStepsPawn = twoStepsPawn
        super.init(invalid: ChessPiece.Invalid, pieces: pieces)
    }

    static func yIndex(ofRank rank: Int, forPlayer player: Player) -> Int {
        return player == Player.white ? 8 - rank : -1 + rank
    }

    convenience init() {
        self.init(pieces: [ChessPiece](repeating: ChessPiece.Empty, count: 64))
    }

    override func clone() -> Board<ChessPiece> {
        return ChessBoard(pieces: pieces.copy(), evaluation: evaluation, whiteKing: whiteKing, blackKing: blackKing, twoStepsPawn: twoStepsPawn)
    }

    override func applyChanges(_ changes: [Effect<ChessPiece>]) {
        // changes.size == 2 -> normal move or capture (incl. promotion); == 3 -> en passant; == 4 -> castling
        let source = changes.first!
        var target = changes.last!
        let capturedOpponent = changes.last!
        if changes.count == 3 {
            // en passant
            target = changes[1]
        }

        let sourcePiece = self[source.coords]
        let targetPiece = target.newPiece
        let capturedPiece = self[capturedOpponent.coords]
        let p = targetPiece.player!
        if capturedPiece.belongs(toPlayer: p.opponent) {
            evaluation -= capturedPiece.value(c: capturedOpponent.coords)
        }

        evaluation += targetPiece.value(c: target.coords) - sourcePiece.value(c: source.coords)
        if targetPiece == ChessPiece.king(ofPlayer: p) {
            if p == Player.white {
                whiteKing = target.coords
            } else {
                blackKing = target.coords
            }
        }

        if targetPiece == ChessPiece.pawn(ofPlayer: p) && target.coords.y == ChessBoard.yIndex(ofRank: 4, forPlayer: p) && source.coords.y == ChessBoard.yIndex(ofRank: 2, forPlayer: p) {
            twoStepsPawn = target.coords
        } else {
            twoStepsPawn = nil
        }

        super.applyChanges(changes)
    }
}
