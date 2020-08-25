#if false
let Ꮻpackage = "de.thm.mow.boardgame.model"
let Ꮻimports = ["de.thm.mow.boardgame.model.support.*"]
#endif

protocol Game {
    var isCurrentPlayerWhite: Bool { get }

    var result: GameResult { get }

    var evaluation: Double { get }

    func getFieldAsString(atCoords coords: Coords) -> String
    func getCurrentTargets() -> [Coords]
    func restart()
    func userAction(atCoords coords: Coords) -> Bool
    func aiMove() -> Bool
    func aiSetSearchDepth(_ depth: Int)
}

class GenericGame<GL: GameLogic>: Game {
    typealias P = GL.P
    private let logic: GL
    private let ai: AI<GL>
    private var currentPlayer = Player.white
    private var currentBoard: Board<P>
    private var currentMoves: [Move<P>]? = nil
    private var currentStepIndex = 0
    init(logic: GL) {
        self.logic = logic
        self.ai = AI(logic: logic)
        currentBoard = logic.getInitialBoard()
    }

    var isCurrentPlayerWhite: Bool {
        return currentPlayer == Player.white
    }

    var result: GameResult {
        return logic.getResult(onBoard: currentBoard, forPlayer: currentPlayer)
    }

    var evaluation: Double {
        logic.evaluateBoard(currentBoard, forPlayer: currentPlayer)
    }

    func getFieldAsString(atCoords coords: Coords) -> String {
        let piece = currentBoard[coords.x, coords.y]
        return String(describing: piece)
    }

    func getCurrentTargets() -> [Coords] {
        var result = [Coords]()
        if let moves = currentMoves {
            for move in moves {
                let target: Coords = move.steps[currentStepIndex].target
                result.append(target)
            }
        }

        return result
    }

    func restart() {
        currentPlayer = Player.white
        currentBoard = logic.getInitialBoard()
        currentMoves = nil
    }

    func userAction(atCoords coords: Coords) -> Bool {
        if result.finished {
            return false
        }

        let (x, y) = coords
        if (currentMoves != nil) {
            for move in currentMoves! {
                let steps = move.steps
                if x == steps[currentStepIndex].target.x && y == steps[currentStepIndex].target.y {
                    currentBoard.applyChanges(steps[currentStepIndex].effects)
                    if (currentStepIndex + 1 == steps.count) {
                        currentMoves = nil
                        currentStepIndex = 0
                        currentPlayer = currentPlayer.opponent
                        print(logic.evaluateBoard(currentBoard, forPlayer: currentPlayer))
                    } else {
                        var remainingMoves = [Move<P>]()
                        for m in currentMoves! {
                            if x == m.steps[currentStepIndex].target.x && y == m.steps[currentStepIndex].target.y {
                                remainingMoves.append(m)
                            }
                        }

                        currentMoves = remainingMoves
                        currentStepIndex += 1
                    }

                    return true
                }
            }
        } else {
            var moves = logic.getMoves(onBoard: currentBoard, forPlayer: currentPlayer, forSourceCoords: coords)
            if (moves.isEmpty) {
                let allMoves = logic.getMoves(onBoard: currentBoard, forPlayer: currentPlayer)
                if allMoves.isEmpty {
                    // add empty dummy move if there is no real move
                    let dummyMove = Move<P>(source: (x, y), steps: [(target: (x, y), effects: [Effect<P>]())], value: nil)
                    moves.append(dummyMove)
                }
            }

            if (!moves.isEmpty) {
                currentMoves = moves
                return true
            }
        }

        return false
    }

    func aiMove() -> Bool {
        if result.finished {
            return false
        }

        let nextMove = ai.getNextMove(onBoard: currentBoard, forPlayer: currentPlayer)
        for step in nextMove.steps {
            currentBoard.applyChanges(step.effects)
        }

        currentPlayer = currentPlayer.opponent
        print(logic.evaluateBoard(currentBoard, forPlayer: currentPlayer))
        return true
    }

    func aiSetSearchDepth(_ depth: Int) {
        ai.maxSearchDepth = depth
    }
}
