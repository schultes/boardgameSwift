#if false
let Ꮻpackage = "de.thm.mow.boardgame.model.chess"
let Ꮻimports = ["de.thm.mow.boardgame.model.Coords", "de.thm.mow.boardgame.model.Player", "de.thm.mow.boardgame.model.support.*"]
#endif

enum ChessPiece: String, CustomStringConvertible {
    case Empty = "  "
    case Invalid = "x"
    case WhitePawn = "♙"
    case BlackPawn = "♟"
    case WhiteKnight = "♘"
    case BlackKnight = "♞"
    case WhiteBishop = "♗"
    case BlackBishop = "♝"
    case WhiteRook = "♖"
    case BlackRook = "♜"
    case WhiteQueen = "♕"
    case BlackQueen = "♛"
    case WhiteKing = "♔"
    case BlackKing = "♚"
    static func pawn(ofPlayer player: Player) -> ChessPiece {
        return player == Player.white ? .WhitePawn : .BlackPawn
    }

    static func knight(ofPlayer player: Player) -> ChessPiece {
        return player == Player.white ? .WhiteKnight : .BlackKnight
    }

    static func bishop(ofPlayer player: Player) -> ChessPiece {
        return player == Player.white ? .WhiteBishop : .BlackBishop
    }

    static func rook(ofPlayer player: Player) -> ChessPiece {
        return player == Player.white ? .WhiteRook : .BlackRook
    }

    static func queen(ofPlayer player: Player) -> ChessPiece {
        return player == Player.white ? .WhiteQueen : .BlackQueen
    }

    static func king(ofPlayer player: Player) -> ChessPiece {
        return player == Player.white ? .WhiteKing : .BlackKing
    }

    static func pawnValue(at c: Coords, forPlayer p: Player) -> Double {
        let borderRankValues = [0.0, -0.01, -0.05, 0.0, 0.1, 0.2]
        var result = 1.0
        let yDelta = (c.y - ChessBoard.yIndex(ofRank: 2, forPlayer: p)).absoluteValue
        switch c.x {
            case 3, 4:
                result += yDelta * 0.08
            default:
                result += borderRankValues[yDelta]
        }

        return result
    }

    static func knightValue(at c: Coords) -> Double {
        return 3.0 + centerPreferringValue(at: c, withWeight: 0.05)
    }

    static func bishopValue(at c: Coords) -> Double {
        return 3.0 + centerPreferringValue(at: c, withWeight: 0.02)
    }

    static func rookValue(at c: Coords) -> Double {
        return 5.0 + centerPreferringValue(at: c, withWeight: 0.01)
    }

    static func queenValue(at c: Coords) -> Double {
        return 9.0 + centerPreferringValue(at: c, withWeight: 0.02)
    }

    static func kingValue(at c: Coords, forPlayer p: Player) -> Double {
        if c.y != ChessBoard.yIndex(ofRank: 1, forPlayer: p) {
            return -0.05
        }

        let xValues = [0.1, 0.2, 0.1, 0.0, 0.0, 0.1, 0.2, 0.1]
        return xValues[c.x]
    }

    static private func centerPreferringValue(at c: Coords, withWeight w: Double) -> Double {
        var result = 0.0
        let xFromCenter = (3.5 - c.x).absoluteValue - 0.5
        let yFromCenter = (3.5 - c.y).absoluteValue - 0.5
        result -= xFromCenter * w
        result -= yFromCenter * w
        return result
    }

    var description: String {
        return rawValue
    }

    func belongs(toPlayer player: Player) -> Bool {
        if ((self == .WhitePawn) || (self == .WhiteKnight) || (self == .WhiteBishop) || (self == .WhiteRook) || (self == .WhiteQueen) || (self == .WhiteKing)) && (player == Player.white) {
            return true
        }

        if ((self == .BlackPawn) || (self == .BlackKnight) || (self == .BlackBishop) || (self == .BlackRook) || (self == .BlackQueen) || (self == .BlackKing)) && (player == Player.black) {
            return true
        }

        return false
    }

    var player: Player? {
        if belongs(toPlayer: Player.white) {
            return Player.white
        }

        if belongs(toPlayer: Player.black) {
            return Player.black
        }

        return nil
    }

    func value(c: Coords) -> Double {
        if let p = player {
            let sign = p.sign
            switch self {
                case ChessPiece.pawn(ofPlayer: p):
                    return sign * ChessPiece.pawnValue(at: c, forPlayer: p)
                case ChessPiece.knight(ofPlayer: p):
                    return sign * ChessPiece.knightValue(at: c)
                case ChessPiece.bishop(ofPlayer: p):
                    return sign * ChessPiece.bishopValue(at: c)
                case ChessPiece.rook(ofPlayer: p):
                    return sign * ChessPiece.rookValue(at: c)
                case ChessPiece.queen(ofPlayer: p):
                    return sign * ChessPiece.queenValue(at: c)
                case ChessPiece.king(ofPlayer: p):
                    return sign * ChessPiece.kingValue(at: c, forPlayer: p)
                default:
                    return 0.0
            }
        }

        return 0.0
    }
}
