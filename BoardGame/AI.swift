//
//  AI.swift
//  BoardGame
//
//  Created by Dominik Schultes on 05.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

class AI<P: Piece, GL: GameLogic where GL.P == P> {
    func getNextMove(game: Game<P, GL>) -> ((Int, Int), Array<((Int, Int), P)>) {
        return getNextMove(game.currentBoard, logic: game.logic, player: game.currentPlayer, maximize: game.currentPlayer == Player.White, depth: 2).1
    }
    
    private func getNextMove(board: Board<P>, logic: GL, player: Player, maximize: Bool, depth: Int) -> (Double, ((Int, Int), Array<((Int, Int), P)>)) {
        var newBoard = Board<P>()
        var bestMove: ((Int, Int), Array<((Int, Int), P)>)?
        var bestValue = 0.0
        let allMoves = GameLogicHelper.getAllMovesOnBoard(board, logic: logic, forPlayer: player)
        for move in allMoves {
            let target = move.1
            if depth == 2 {
                print("depth: \(depth), (\(move.0.0), \(move.0.1)), best value: \(bestValue)")
            }
            board.copyToBoard(newBoard)
            newBoard.applyChanges(target.1)
            var currentValue = 0.0
            if (depth > 0) {
                currentValue = getNextMove(newBoard, logic: logic, player: player.opponent(), maximize: !maximize, depth: depth-1).0
            } else {
                currentValue = logic.evaluateBoard(newBoard)
            }
            if depth == 2 {
                println(", current value: \(currentValue) ")
            }
            if (!bestMove) || ((currentValue > bestValue) == maximize) {
                bestMove = target
                bestValue = currentValue
            }
        }
        if bestMove {return (bestValue, bestMove!)}
        
        // return empty dummy move if there is no real move
        return (logic.evaluateBoard(board), ((0, 0), Array<((Int, Int), P)>()))
    }
}