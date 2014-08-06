//
//  ViewController.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let BOARD_SIZE = 8
    
    typealias MyPiece = ReversiPiece
    typealias MyGameLogic = ReversiGameLogic
    
    @IBOutlet weak var firstBoardField: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    var fields = [[UIButton?]]()
    let game = Game<MyPiece, MyGameLogic>(logic: MyGameLogic())
    var ai: AI<MyPiece, MyGameLogic>?
    
    var currentMoves: [Move<MyPiece>]?
    
    @IBAction func restart() {
        if game.currentPlayer == Player.Black && !game.logic.getResult(game.currentBoard).finished {return}
        game.restart()
        refreshUI()
    }
    
    @IBAction func fieldClick(sender: UIButton) {
        if game.currentPlayer == Player.Black {return}
        if game.logic.getResult(game.currentBoard).finished {return}
        
        let coords = getFieldCoords(sender)
        let (x, y) = coords
        
        if currentMoves {
            for move in currentMoves! {
                // TODO: work with multiple targets
                if x == move.targets[0].x && y == move.targets[0].y {
                    currentMoves = nil
                    userMove(move)
                    break
                }
            }
        } else {
            var moves = game.logic.getMovesOnBoard(game.currentBoard, forPlayer: game.currentPlayer, forSourceCoords: coords)
            if (moves.isEmpty) {
                if GameLogicHelper.getAllMovesOnBoard(game.currentBoard, withLogic: game.logic, forPlayer: game.currentPlayer).isEmpty {
                    // add empty dummy move if there is no real move
                    let dummyMove = Move<MyPiece>(source: (x, y), targets: [(x, y)], effects: Move<MyPiece>.Patch(), value: nil)
                    moves += dummyMove
                }
            }
            println("\(x) \(y)")
            if (!moves.isEmpty) {
                currentMoves = moves
                refreshUI()
            }
        }
    }
    
    private func userMove(move: Move<MyPiece>) {
        game.currentBoard.applyChanges(move.effects)
        game.currentPlayer = game.currentPlayer.opponent()
        println(game.logic.evaluateBoard(game.currentBoard))
        refreshUI()
        
        aiMove()
    }
    
    private func aiMove() {
        if game.logic.getResult(game.currentBoard).finished {return}
        let globalQueuePriority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(globalQueuePriority, 0)) {
            let nextMove = self.ai!.getNextMoveOnBoard(self.game.currentBoard, forPlayer: self.game.currentPlayer)
            self.game.currentBoard.applyChanges(nextMove.effects)
            
            dispatch_async(dispatch_get_main_queue()) {
                println(self.game.logic.evaluateBoard(self.game.currentBoard))
                self.game.currentPlayer = self.game.currentPlayer.opponent()
                self.refreshUI()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ai = AI<MyPiece, MyGameLogic>(logic: game.logic)
        initFields()
        refreshUI()
    }
    
    private func initFields() {
        // outlet collection would probably be nicer, but in Xcode 6 beta 4 there are problems with it!
        for _ in 0..<BOARD_SIZE {
            fields += [UIButton?](count: BOARD_SIZE, repeatedValue: nil)
        }
        for view in self.view.subviews {
            if let field = view as? UIButton {
                if field.tag != 1 {continue}
                let (x, y) = getFieldCoords(field)
                fields[x][y] = field
            }
        }
    }
    
    private func refreshUI() {
        // draw board
        for x in 0..<BOARD_SIZE {
            for y in 0..<BOARD_SIZE {
                if let field = fields[x][y] {
                    if (x+y) % 2 == 0 {
                        field.backgroundColor = UIColor.whiteColor()
                    }
                    field.selected = false
                    field.setTitle(game.currentBoard[x, y].toRaw(), forState: .Normal)
                }
            }
        }
        
        // set selected state
        if let moves = currentMoves {
            for move in moves {
                // TODO: support multiple targets
                if let field = fields[move.targets[0].x][move.targets[0].y] {
                    field.selected = true
                }
            }
        }

        // update state label
        let result = game.logic.getResult(game.currentBoard)
        if result.finished {
            if let winner = result.winner {
                let player = winner == .White ? "Weiß" : "Schwarz"
                stateLabel.text = player + " gewinnt"
            } else {
                stateLabel.text = "Unentschieden"
            }
        } else {
            let player = game.currentPlayer == .White ? "Weiß" : "Schwarz"
            stateLabel.text = player + " am Zug"
        }
    }
    
    private func getFieldCoords(field: UIButton) -> Coords {
        let x = Int((field.frame.origin.x - firstBoardField.frame.origin.x) / field.frame.size.width)
        let y = Int((field.frame.origin.y - firstBoardField.frame.origin.y) / field.frame.size.height)
        return (x, y)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

