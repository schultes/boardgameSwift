#if false
let Ꮻpackage = "de.thm.mow.boardgame.model"
let Ꮻimports = ["de.thm.mow.boardgame.model.support.*"]
#endif

class AI<GL: GameLogic> {
    typealias P = GL.P
    let logic: GL
    init(logic: GL) {
        self.logic = logic
    }

    var maxSearchDepth = 2
    func performMove(onBoard board: Board<P>, forPlayer player: Player, finished: @escaping () -> ()) {
        let allMoves = logic.getMoves(onBoard: board, forPlayer: player)
        allMoves.asyncMap(transform: {
            self.getValue(onBoard: board.changedCopy(move: $0), forPlayer: player.opponent, withDepth: self.maxSearchDepth - 2)
        }

        , processResult: {
            var bestValue = 0.0
            var bestMoves = [Move<P>]()
            allMoves.zip($0).forEach {
                let currentValue = $0.1
                let almostTheSame = bestMoves.isNotEmpty() && (bestValue - currentValue).absoluteValue < 0.02
                let improvement = bestMoves.isEmpty || (currentValue > bestValue) == player.isMaximizing
                if improvement && !almostTheSame {
                    bestMoves.removeAll()
                }

                if improvement || almostTheSame {
                    bestValue = currentValue
                    bestMoves.append($0.0)
                }
            }

            if bestMoves.isNotEmpty() {
                board.applyChanges(move: bestMoves.randomElement()!)
            }

            finished()
        })
    }

    private func getValue(onBoard board: Board<P>, forPlayer player: Player, withDepth depth: Int) -> Double {
        let allMoves = depth < 0 ? [] : logic.getMoves(onBoard: board, forPlayer: player)
        var bestValue: Double? = nil
        allMoves.forEach {
            let value = getValue(onBoard: board.changedCopy(move: $0), forPlayer: player.opponent, withDepth: depth - 1)
            if bestValue == nil || (value > bestValue!) == player.isMaximizing {
                bestValue = value
            }
        }

        return bestValue ?? logic.evaluateBoard(board, forPlayer: player)
    }
}
