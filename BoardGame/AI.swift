//
//  AI.swift
//  BoardGame
//
//  Created by Dominik Schultes on 05.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

class AI<P: Piece, GL: GameLogic where GL.P == P> {
    var maxSearchDepth = 2
    let logic: GL
    
    init(logic: GL) {
        self.logic = logic
    }
    
    func getNextMoveOnBoard(board: Board<P>, forPlayer player: Player) -> Move<P> {
        return getNextMoveOnBoard(board, forPlayer: player, maximizingValue: player == Player.White, withDepth: maxSearchDepth)
    }
    
    private func getNextMoveOnBoard(board: Board<P>, forPlayer player: Player, maximizingValue: Bool, withDepth depth: Int) -> Move<P> {
        var newBoard = Board<P>()
        var bestMove: Move<P>?
        var allMoves = logic.getMovesOnBoard(board, forPlayer: player)
        
        for var i = 0; i < allMoves.count; i++ {
            var move = allMoves[i]
            if depth == maxSearchDepth {
                print("depth: \(depth), (\(move.source)), best value: \(bestMove?.value)")
            }
            board.copyToBoard(newBoard)
            for step in move.steps {
                newBoard.applyChanges(step.effects)
            }
            if (depth > 0) {
                move.value = getNextMoveOnBoard(newBoard, forPlayer: player.opponent, maximizingValue: !maximizingValue, withDepth: depth-1).value!
            } else {
                move.value = logic.evaluateBoard(newBoard)
            }
            if depth == maxSearchDepth {
                println(", current value: \(move.value!) ")
            }
            if (!bestMove) || ((move.value > bestMove!.value) == maximizingValue) {
                bestMove = move
            }
        }
        if (!bestMove) {
            // return empty dummy move if there is no real move
            bestMove = Move<P>(coords: (0, 0), value: logic.evaluateBoard(board))
        }
        assert(bestMove!.value) // value of next move is guaranteed to be set
        return bestMove!
    }
}