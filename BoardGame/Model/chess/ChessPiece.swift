#if false
let Ꮻpackage = "de.thm.mow.boardgame.model.chess"
let Ꮻimports = ["de.thm.mow.boardgame.model.Player", "de.thm.mow.boardgame.model.support.*"]
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

    var value: Double {
        if let p = player {
            let sign = p.sign
            switch self {
                case ChessPiece.pawn(ofPlayer: p):
                    return sign * 1.0
                case ChessPiece.knight(ofPlayer: p):
                    return sign * 3.0
                case ChessPiece.bishop(ofPlayer: p):
                    return sign * 3.0
                case ChessPiece.rook(ofPlayer: p):
                    return sign * 5.0
                case ChessPiece.queen(ofPlayer: p):
                    return sign * 9.0
                default:
                    return 0.0
            }
        }

        return 0.0
    }
}
