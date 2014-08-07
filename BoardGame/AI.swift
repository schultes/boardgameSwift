//
//  AI.swift
//  BoardGame
//
//  Created by Dominik Schultes on 05.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

class AI<P: Piece, GL: GameLogic where GL.P == P> {
    let MAX_DEPTH = 4
    let logic: GL
    
    init(logic: GL) {
        self.logic = logic
    }
    
    func getNextMoveOnBoard(board: Board<P>, forPlayer player: Player) -> Move<P> {
        return getNextMoveOnBoard(board, forPlayer: player, maximizingValue: player == Player.White, withDepth: MAX_DEPTH)
    }
    
    private func getNextMoveOnBoard(board: Board<P>, forPlayer player: Player, maximizingValue: Bool, withDepth depth: Int) -> Move<P> {
        var newBoard = Board<P>()
        var bestMove: Move<P>?
        var allMoves = GameLogicHelper.getAllMovesOnBoard(board, withLogic: logic, forPlayer: player)
        
        for var i = 0; i < allMoves.count; i++ {
            var move = allMoves[i]
            if depth == MAX_DEPTH {
                print("depth: \(depth), (\(move.source)), best value: \(bestMove?.value)")
            }
            board.copyToBoard(newBoard)
            newBoard.applyChanges(move.effects)
            if (depth > 0) {
                move.value = getNextMoveOnBoard(newBoard, forPlayer: player.opponent(), maximizingValue: !maximizingValue, withDepth: depth-1).value!
            } else {
                move.value = logic.evaluateBoard(newBoard)
            }
            if depth == MAX_DEPTH {
                println(", current value: \(move.value!) ")
            }
            if (!bestMove) || ((move.value > bestMove!.value) == maximizingValue) {
                bestMove = move
            }
        }
        if (!bestMove) {
            // return empty dummy move if there is no real move
            bestMove = Move<P>(source: (0, 0), targets: [(0, 0)], effects: Move<P>.Patch(), value: logic.evaluateBoard(board))
        }
        assert(bestMove!.value) // value of next move is guaranteed to be set
        return bestMove!
    }
}