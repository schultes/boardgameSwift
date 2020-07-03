#if false
let Ꮻpackage = "de.thm.mow.boardgame.model.checkers"
let Ꮻimports = ["de.thm.mow.boardgame.model.Player", "de.thm.mow.boardgame.model.support.*"]
#endif

enum CheckersPiece: String, CustomStringConvertible {
    case Empty = "  "
    case Invalid = "x"
    case WhiteMan = "◎"
    case BlackMan = "◉"
    case WhiteKing = "♕"
    case BlackKing = "♛"
    static func getMan(forPlayer player: Player) -> CheckersPiece {
        return player == Player.white ? .WhiteMan : .BlackMan
    }

    static func getKing(forPlayer player: Player) -> CheckersPiece {
        return player == Player.white ? .WhiteKing : .BlackKing
    }

    var description: String {
        return rawValue
    }

    func belongs(toPlayer player: Player) -> Bool {
        if ((self == .WhiteMan) || (self == .WhiteKing)) && (player == Player.white) {
            return true
        }

        if ((self == .BlackMan) || (self == .BlackKing)) && (player == Player.black) {
            return true
        }

        return false
    }
}
