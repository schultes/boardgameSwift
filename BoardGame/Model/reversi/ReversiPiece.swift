enum ReversiPiece: String, CustomStringConvertible {
    case Empty = "  "
    case Invalid = "x"
    case White = "◎"
    case Black = "◉"
    static func getPiece(forPlayer player: Player) -> ReversiPiece {
        return player == Player.white ? .White : .Black
    }

    var description: String {
        return rawValue
    }

    func belongs(toPlayer player: Player) -> Bool {
        if ((self == .White) && (player == Player.white)) {
            return true
        }

        if ((self == .Black) && (player == Player.black)) {
            return true
        }

        return false
    }
}
