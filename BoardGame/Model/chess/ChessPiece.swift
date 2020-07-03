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
    static func getPawn(forPlayer player: Player) -> ChessPiece {
        return player == Player.white ? .WhitePawn : .BlackPawn
    }
    
    static func getKnight(forPlayer player: Player) -> ChessPiece {
        return player == Player.white ? .WhiteKnight : .BlackKnight
    }
    
    static func getBishop(forPlayer player: Player) -> ChessPiece {
        return player == Player.white ? .WhiteBishop : .BlackBishop
    }
    
    static func getRook(forPlayer player: Player) -> ChessPiece {
        return player == Player.white ? .WhiteRook : .BlackRook
    }
    
    static func getQueen(forPlayer player: Player) -> ChessPiece {
        return player == Player.white ? .WhiteQueen : .BlackQueen
    }

    static func getKing(forPlayer player: Player) -> ChessPiece {
        return player == Player.white ? .WhiteKing : .BlackKing
    }

    var description: String {
        return rawValue
    }

    func belongs(toPlayer player: Player) -> Bool {
        if ((self == .WhitePawn) || (self == .WhiteKing)) && (player == Player.white) {
            return true
        }

        if ((self == .BlackPawn) || (self == .BlackKing)) && (player == Player.black) {
            return true
        }

        return false
    }
}
