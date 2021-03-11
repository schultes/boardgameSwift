#if false
let Ꮻpackage = "de.thm.mow.boardgame.model"
#endif

enum Player {
    case white, black
    var opponent: Player {
        self == .white ? .black : .white
    }

    var sign: Double {
        self == .white ? +1.0 : -1.0
    }

    var isMaximizing: Bool {
        self == .white
    }
}
