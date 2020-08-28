#if false
let Ꮻpackage = "de.thm.mow.boardgame.model.chess"
let Ꮻimports = ["de.thm.mow.boardgame.model.*", "de.thm.mow.boardgame.model.support.*"]
#endif

class ChessGameLogic: GameLogic {
    typealias P = ChessPiece
    private func kingCoords(board: Board<P>, player: Player) -> Coords {
        return player == Player.white ? (board as! ChessBoard).whiteKing : (board as! ChessBoard).blackKing
    }

    private func isThreatened(board: Board<P>, player: Player, c: Coords) -> Bool {
        let yDir = player == Player.white ? -1 : +1
        for x in [-1, +1] {
            if board[c.x + x, c.y + yDir] == P.pawn(ofPlayer: player.opponent) {
                return true
            }
        }

        for y in [-2, -1, +1, +2] {
            for x in [-1, +1] {
                let xFactor = y == 2 || y == -2 ? 1 : 2
                if board[c.x + x * xFactor, c.y + y] == P.knight(ofPlayer: player.opponent) {
                    return true
                }
            }
        }

        for y in -1...1 {
            for x in -1...1 {
                if x == 0 && y == 0 {
                    continue
                }

                let isStraight = x == 0 || y == 0
                let isDiagonal = !isStraight
                for d in 1...7 {
                    let currentPiece = board[c.x + x * d, c.y + y * d]
                    if currentPiece == P.king(ofPlayer: player.opponent) && d == 1 {
                        return true
                    }

                    if currentPiece == P.queen(ofPlayer: player.opponent) {
                        return true
                    }

                    if currentPiece == P.rook(ofPlayer: player.opponent) && isStraight {
                        return true
                    }

                    if currentPiece == P.bishop(ofPlayer: player.opponent) && isDiagonal {
                        return true
                    }

                    if currentPiece != P.Empty {
                        break
                    }
                }
            }
        }

        return false
    }

    private func isInCheck(board: Board<P>, player: Player) -> Bool {
        return isThreatened(board: board, player: player, c: kingCoords(board: board, player: player))
    }

    func getInitialBoard() -> Board<P> {
        let board = ChessBoard()
        for p in [Player.white, Player.black] {
            var y = ChessBoard.yIndex(ofRank: 1, forPlayer: p)
            board[0, y] = P.rook(ofPlayer: p)
            board[1, y] = P.knight(ofPlayer: p)
            board[2, y] = P.bishop(ofPlayer: p)
            board[3, y] = P.queen(ofPlayer: p)
            board[4, y] = P.king(ofPlayer: p)
            board[5, y] = P.bishop(ofPlayer: p)
            board[6, y] = P.knight(ofPlayer: p)
            board[7, y] = P.rook(ofPlayer: p)
            y = ChessBoard.yIndex(ofRank: 2, forPlayer: p)
            for x in 0...7 {
                board[x, y] = P.pawn(ofPlayer: p)
            }
        }

        return board
    }

    func getMoves(onBoard board: Board<P>, forPlayer player: Player, forSourceCoords sc: Coords) -> [Move<P>] {
        var moves = [Move<P>]()
        addMoves(moves: &moves, board: board, player: player, sc: sc)
        return moves
    }

    private func addMoves(moves: inout [Move<P>], board: Board<P>, player: Player, sc: Coords) {
        let srcPiece = board[sc.x, sc.y]
        if srcPiece == P.pawn(ofPlayer: player) {
            let yDir = player == Player.white ? -1 : +1
            if sc.y == ChessBoard.yIndex(ofRank: 2, forPlayer: player) && board[sc.x, sc.y + yDir] == P.Empty {
                addMove(moves: &moves, board: board, player: player, sc: sc, deltaX: 0, deltaY: 2 * yDir, moveAllowed: true, captureAllowed: false)
            }

            addMove(moves: &moves, board: board, player: player, sc: sc, deltaX: 0, deltaY: yDir, moveAllowed: true, captureAllowed: false)
            for x in [-1, +1] {
                addMove(moves: &moves, board: board, player: player, sc: sc, deltaX: x, deltaY: yDir, moveAllowed: false, captureAllowed: true)
            }

            // en passant
            if let opponentPawn = (board as! ChessBoard).twoStepsPawn {
                if (sc.x - opponentPawn.x).absoluteValue == 1 && sc.y == opponentPawn.y {
                    let tc: Coords = (opponentPawn.x, sc.y + yDir)
                    let effects = [(coords: sc, newPiece: P.Empty), (coords: tc, newPiece: srcPiece), (coords: opponentPawn, newPiece: P.Empty)]
                    addMove(moves: &moves, board: board, player: player, sc: sc, tc: tc, effects: effects)
                }
            }
        }

        if srcPiece == P.knight(ofPlayer: player) {
            for y in [-2, -1, +1, +2] {
                for x in [-1, +1] {
                    let xFactor = y == 2 || y == -2 ? 1 : 2
                    addMove(moves: &moves, board: board, player: player, sc: sc, deltaX: x * xFactor, deltaY: y)
                }
            }
        }

        if srcPiece == P.king(ofPlayer: player) || srcPiece == P.queen(ofPlayer: player) || srcPiece == P.bishop(ofPlayer: player) || srcPiece == P.rook(ofPlayer: player) {
            let maxDistance = srcPiece == P.king(ofPlayer: player) ? 1 : 7
            let straight = srcPiece == P.bishop(ofPlayer: player) ? false : true
            let diagonal = srcPiece == P.rook(ofPlayer: player) ? false : true
            for y in -1...1 {
                for x in -1...1 {
                    if x == 0 && y == 0 {
                        continue
                    }

                    if !straight && (x == 0 || y == 0) {
                        continue
                    }

                    if !diagonal && x != 0 && y != 0 {
                        continue
                    }

                    for d in 1...maxDistance {
                        addMove(moves: &moves, board: board, player: player, sc: sc, deltaX: x * d, deltaY: y * d)
                        if board[sc.x + x * d, sc.y + y * d] != P.Empty {
                            break
                        }
                    }
                }
            }
        }

        // Castling
        // (At the moment, we don't check whether King or Rook have been moved before.)
        if srcPiece == P.king(ofPlayer: player) && !isInCheck(board: board, player: player) {
            for x in [-1, +1] {
                let queenside = x == -1
                let rookTarget: Coords = (sc.x + 1 * x, sc.y)
                let kingTarget: Coords = (sc.x + 2 * x, sc.y)
                let rookSource: Coords = queenside ? (sc.x + 4 * x, sc.y) : (sc.x + 3 * x, sc.y)
                var allowed = true
                for c in [rookTarget, kingTarget] {
                    if board[c] != P.Empty || isThreatened(board: board, player: player, c: c) {
                        allowed = false
                    }
                }

                if board[rookSource] != P.rook(ofPlayer: player) {
                    allowed = false
                }

                if queenside && board[sc.x - 3, sc.y] != P.Empty {
                    allowed = false
                }

                if allowed {
                    let effects = [(coords: sc, newPiece: P.Empty), (coords: rookTarget, newPiece: P.rook(ofPlayer: player)), (coords: rookSource, newPiece: P.Empty), (coords: kingTarget, newPiece: P.king(ofPlayer: player))]
                    moves += [Move<P>(source: sc, steps: [(target: kingTarget, effects: effects)], value: nil)]
                }
            }
        }
    }

    private func addMove(moves: inout [Move<P>], board: Board<P>, player: Player, sc: Coords, deltaX: Int, deltaY: Int, moveAllowed: Bool = true, captureAllowed: Bool = true) {
        let tc: Coords = (sc.x + deltaX, sc.y + deltaY)
        if moveAllowed && board[tc.x, tc.y] == P.Empty || captureAllowed && board[tc.x, tc.y].belongs(toPlayer: player.opponent) {
            var targetPiece = board[sc.x, sc.y]
            if targetPiece == P.pawn(ofPlayer: player) && tc.y == ChessBoard.yIndex(ofRank: 1, forPlayer: player.opponent) {
                targetPiece = P.queen(ofPlayer: player) // promotion
            }

            let effects = [(coords: sc, newPiece: P.Empty), (coords: tc, newPiece: targetPiece)]
            addMove(moves: &moves, board: board, player: player, sc: sc, tc: tc, effects: effects)
        }
    }

    private func addMove(moves: inout [Move<P>], board: Board<P>, player: Player, sc: Coords, tc: Coords, effects: [Effect<P>]) {
        let newMove = Move<P>(source: sc, steps: [(target: tc, effects: effects)], value: nil)
        let newBoard = board.clone()
        newBoard.applyChanges(effects)
        if !isInCheck(board: newBoard, player: player) {
            moves += [newMove]
        }
    }

    func getMoves(onBoard board: Board<P>, forPlayer player: Player) -> [Move<P>] {
        var allMoves = [Move<P>]()
        for x in 0...7 {
            for y in 0...7 {
                addMoves(moves: &allMoves, board: board, player: player, sc: (x, y))
            }
        }

        return allMoves
    }

    func evaluateBoard(_ board: Board<P>, forPlayer player: Player) -> Double {
        var value = 0.0
        if isInCheck(board: board, player: player) && getMoves(onBoard: board, forPlayer: player).isEmpty {
            value -= player.sign * 100.0
        }

        value += (board as! ChessBoard).evaluation
        return value
    }

    func getResult(onBoard board: Board<P>, forPlayer player: Player) -> GameResult {
        var finished = false
        var winner: Player? = nil
        if getMoves(onBoard: board, forPlayer: player).isEmpty {
            finished = true
            winner = isInCheck(board: board, player: player) ? player.opponent : nil
        }

        return (finished, winner)
    }
}
