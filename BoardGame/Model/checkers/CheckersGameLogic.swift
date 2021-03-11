#if false
let Ꮻpackage = "de.thm.mow.boardgame.model.checkers"
let Ꮻimports = ["de.thm.mow.boardgame.model.*", "de.thm.mow.boardgame.model.support.*"]
#endif

class CheckersGameLogic: GameLogic {
    typealias P = CheckersPiece
    func getInitialBoard() -> Board<P> {
        let board = Board<P>(empty: P.Empty, invalid: P.Invalid)
        for x in 0..<board.columns {
            for y in 0..<3 {
                if (x + y) % 2 == 1 {
                    board[x, y] = P.BlackMan
                }
            }

            for y in board.rows - 3..<board.rows {
                if (x + y) % 2 == 1 {
                    board[x, y] = P.WhiteMan
                }
            }
        }

        return board
    }

    func getMoves(onBoard board: Board<P>, forPlayer player: Player, forSourceCoords sc: Coords) -> [Move<P>] {
        var result = [Move<P>]()
        let allMoves = getMoves(onBoard: board, forPlayer: player)
        for move in allMoves {
            if move.source.x == sc.x && move.source.y == sc.y {
                result.append(move)
            }
        }

        return result
    }

    func getMoves(onBoard board: Board<P>, forPlayer player: Player) -> [Move<P>] {
        return getMoves(onBoard: board, forPlayer: player, ignoreCaptureObligation: false)
    }

    private func getMoves(onBoard board: Board<P>, forPlayer player: Player, ignoreCaptureObligation: Bool) -> [Move<P>] {
        var normalMoves = [Move<P>]()
        var captureMoves = [Move<P>]()
        let forwardDirection = player == Player.white ? -1 : 1
        for x in 0..<board.columns {
            for y in 0..<board.rows {
                let sc: Coords = (x, y)
                let sourcePiece = board[sc.x, sc.y]
                if sourcePiece.belongs(toPlayer: player) {
                    let sourcePieceIsMan = (sourcePiece == P.getMan(forPlayer: player))
                    let range = sourcePieceIsMan ? 1...1 : 1...board.rows - 1
                    let yDirections = sourcePieceIsMan ? [forwardDirection] : [-1, 1]
                    for dy in yDirections {
                        for dx in [-1, 1] {
                            for i in range {
                                let tx = sc.x + i * dx
                                let ty = sc.y + i * dy
                                let tc: Coords = (tx, ty)
                                if board[tx, ty] != P.Empty {
                                    break
                                }

                                let targetPiece = getTargetPiece(onBoard: board, forPlayer: player, atCoords: tc, forSourcePiece: sourcePiece)
                                normalMoves.append(Move<P>(source: sc, steps: [(target: tc, effects: [(coords: sc, newPiece: P.Empty), (coords: tc, newPiece: targetPiece)])]))
                            }
                        }
                    }

                    // capture
                    let arrayOfSteps = recursiveCapture(onBoard: board, forPlayer: player, forCurrentCoords: sc, withRange: range, inYdirections: yDirections)
                    for steps in arrayOfSteps {
                        captureMoves.append(Move<P>(source: sc, steps: steps))
                    }
                }
            }
        }

        if (ignoreCaptureObligation) {
            return captureMoves + normalMoves
        }

        return !captureMoves.isEmpty ? captureMoves : normalMoves
    }

    private func recursiveCapture(onBoard board: Board<P>, forPlayer player: Player, forCurrentCoords cc: Coords, withRange range: CountableClosedRange<Int>, inYdirections yDirections: Array<Int>) -> [[Step<P>]] {
        var result = [[Step<P>]]()
        for dy in yDirections {
            for dx in [-1, 1] {
                for i in range {
                    let tx = cc.x + i * dx
                    let ty = cc.y + i * dy
                    let tc: Coords = (tx, ty)
                    if board[tx, ty].belongs(toPlayer: player) {
                        break
                    }

                    if board[tx, ty].belongs(toPlayer: player.opponent) {
                        let t2x = tx + dx
                        let t2y = ty + dy
                        let t2c: Coords = (t2x, t2y)
                        if board[t2x, t2y] == P.Empty {
                            let sourcePiece = board[cc.x, cc.y]
                            let targetPiece = getTargetPiece(onBoard: board, forPlayer: player, atCoords: t2c, forSourcePiece: sourcePiece)
                            let effects: [Effect<P>] = [(coords: cc, newPiece: P.Empty), (coords: tc, newPiece: P.Empty), (coords: t2c, newPiece: targetPiece)]
                            let thisSteps = [(target: t2c, effects: effects)]
                            if sourcePiece != targetPiece {
                                // promotion took place (man -> king): stop recursion!
                                result.append(thisSteps)
                            } else {
                                let newBoard = board.changedCopy(changes: effects)
                                let arrayOfSubsequentSteps = recursiveCapture(onBoard: newBoard, forPlayer: player, forCurrentCoords: t2c, withRange: range, inYdirections: yDirections)
                                if arrayOfSubsequentSteps.isEmpty {
                                    result.append(thisSteps)
                                } else {
                                    for subsequentSteps in arrayOfSubsequentSteps {
                                        let concatenatedSteps = thisSteps + subsequentSteps
                                        result.append(concatenatedSteps)
                                    }
                                }
                            }
                        }

                        break
                    }
                }
            }
        }

        return result
    }

    private func getTargetPiece(onBoard board: Board<P>, forPlayer player: Player, atCoords coords: Coords, forSourcePiece sourcePiece: P) -> P {
        let finalRow = player == Player.white ? 0 : board.rows - 1
        if (coords.y == finalRow) {
            return P.getKing(forPlayer: player)
        }

        return sourcePiece
    }

    func evaluateBoard(_ board: Board<P>, forPlayer player: Player) -> Double {
        var result = 0.0
        for x in 0..<board.columns {
            for y in 0..<board.rows {
                if board[x, y].belongs(toPlayer: Player.white) {
                    result += 1
                }

                if board[x, y] == P.WhiteKing {
                    result += 3
                }

                if board[x, y].belongs(toPlayer: Player.black) {
                    result -= 1
                }

                if board[x, y] == P.BlackKing {
                    result -= 3
                }
            }
        }

        // mobility
        let whiteMoves = getMoves(onBoard: board, forPlayer: Player.white, ignoreCaptureObligation: true)
        let blackMoves = getMoves(onBoard: board, forPlayer: Player.black, ignoreCaptureObligation: true)
        result += Double(whiteMoves.count)
        result -= Double(blackMoves.count)
        return result
    }

    func getResult(onBoard board: Board<P>, forPlayer player: Player) -> GameResult {
        let movesOfCurrentPlayer = getMoves(onBoard: board, forPlayer: player)
        if movesOfCurrentPlayer.isEmpty {
            return (finished: true, winner: player.opponent)
        }

        return (finished: false, winner: nil)
    }
}
