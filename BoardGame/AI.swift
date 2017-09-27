//
//  AI.swift
//  BoardGame
//
//  Created by Dominik Schultes on 05.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

class AI<GL: GameLogic> {
    typealias P = GL.P
    
    var maxSearchDepth = 2
    let logic: GL
    
    init(logic: GL) {
        self.logic = logic
    }
    
    func getNextMove(onBoard board: Board<P>, forPlayer player: Player) -> Move<P> {
        return getNextMove(onBoard: board, forPlayer: player, maximizingValue: player == Player.white, withDepth: maxSearchDepth)
    }
    
    private func getNextMove(onBoard board: Board<P>, forPlayer player: Player, maximizingValue: Bool, withDepth depth: Int) -> Move<P> {
        let newBoard = Board<P>()
        var bestMove: Move<P>?
        var allMoves = logic.getMoves(onBoard: board, forPlayer: player)
        
        for i in 0 ..< allMoves.count {
            var move = allMoves[i]
            if depth == maxSearchDepth {
                print("depth: \(depth), (\(move.source)), best value: \(bestMove?.value as Double?)", terminator: "")
            }
            board.copy(toBoard: newBoard)
            for step in move.steps {
                newBoard.applyChanges(step.effects)
            }
            if (depth > 0) {
                move.value = getNextMove(onBoard: newBoard, forPlayer: player.opponent, maximizingValue: !maximizingValue, withDepth: depth-1).value!
            } else {
                move.value = logic.evaluateBoard(newBoard)
            }
            if depth == maxSearchDepth {
                print(", current value: \(move.value!) ")
            }
            if (bestMove == nil) || ((move.value! > bestMove!.value!) == maximizingValue) {
                bestMove = move
            }
        }
        if (bestMove == nil) {
            // return empty dummy move if there is no real move
            bestMove = Move<P>(coords: (0, 0), value: logic.evaluateBoard(board))
        }
        assert(bestMove!.value != nil) // value of next move is guaranteed to be set
        return bestMove!
    }
}
