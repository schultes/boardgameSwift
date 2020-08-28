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
        var bestMoves = [Move<P>]()
        let allMoves = logic.getMoves(onBoard: board, forPlayer: player)
        for i in 0..<allMoves.count {
            var move = allMoves[i]
            let newBoard = board.clone()
            for step in move.steps {
                newBoard.applyChanges(step.effects)
            }

            if depth > 0 {
                let nextMove = getNextMove(onBoard: newBoard, forPlayer: player.opponent, maximizingValue: !maximizingValue, withDepth: depth - 1)
                move.value = nextMove.value!
            } else {
                move.value = logic.evaluateBoard(newBoard, forPlayer: player.opponent)
            }

            if depth == maxSearchDepth {
                print("depth: \(depth), (\(move.source)), best value: \(bestMoves.first?.value ?? 0), size = \(bestMoves.count), current value: \(move.value!)")
            }

            if bestMoves.isEmpty || (bestMoves.first!.value! - move.value!).absoluteValue < 0.01 {
                bestMoves.append(move)
            } else {
                if (move.value! > bestMoves.first!.value!) == maximizingValue {
                    bestMoves.removeAll()
                    bestMoves.append(move)
                }
            }
        }

        if bestMoves.isEmpty {
            // return empty dummy move if there is no real move
            bestMoves.append(Move<P>(source: (x: 0, y: 0), steps: [(target: (x: 0, y: 0), effects: [Effect<P>]())], value: logic.evaluateBoard(board, forPlayer: player)))
        }

        return bestMoves.randomElement()!
    }
}
