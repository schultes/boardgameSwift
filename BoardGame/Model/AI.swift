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
    func getNextMove(onBoard board: Board<P>, forPlayer player: Player) -> Move<P> {
        return getNextMove(onBoard: board, forPlayer: player, maximizingValue: player == Player.white, withDepth: maxSearchDepth)
    }

    private func getNextMove(onBoard board: Board<P>, forPlayer player: Player, maximizingValue: Bool, withDepth depth: Int) -> Move<P> {
        var bestMove: Move<P>? = nil
        let allMoves = logic.getMoves(onBoard: board, forPlayer: player)
        for i in 0..<allMoves.count {
            var move = allMoves[i]
            let newBoard = Board<P>(board: board)
            for step in move.steps {
                newBoard.applyChanges(step.effects)
            }

            if depth > 0 {
                let nextMove = getNextMove(onBoard: newBoard, forPlayer: player.opponent, maximizingValue: !maximizingValue, withDepth: depth - 1)
                move.value = nextMove.value!
            } else {
                move.value = logic.evaluateBoard(newBoard)
            }

            if depth == maxSearchDepth {
                print("depth: \(depth), (\(move.source)), best value: \(bestMove?.value ?? 0), current value: \(move.value!)")
            }

            if (bestMove == nil) || ((move.value! > bestMove!.value!) == maximizingValue) {
                bestMove = move
            }
        }

        if (bestMove == nil) {
            // return empty dummy move if there is no real move
            bestMove = Move<P>(source: (x: 0, y: 0), steps: [(target: (x: 0, y: 0), effects: [Effect<P>]())], value: logic.evaluateBoard(board))
        }

        assert(bestMove!.value != nil)
        return bestMove!
    }
}
