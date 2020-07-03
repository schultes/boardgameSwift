#if false
let Ꮻpackage = "de.thm.mow.boardgame.model"
#endif

enum Player {
    case white, black
    var opponent: Player {
        self == .white ? .black : .white
    }
}
