enum Player {
    case white, black
    var opponent: Player {
        self == .white ? .black : .white
    }
}
