//
//  ViewController.swift
//  BoardGame
//
//  Created by Dominik Schultes on 04.08.14.
//  Copyright (c) 2014 THM. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    typealias MyPiece = ReversiPiece
    typealias MyGameLogic = ReversiGameLogic
    
    @IBOutlet weak var firstBoardField: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    let game = Game<MyPiece, MyGameLogic>(logic: MyGameLogic())
    let ai = AI<MyPiece, MyGameLogic>()
    
    var currentTargets: Array<((Int, Int), Array<((Int, Int), MyPiece)>)>?
    
    @IBAction func fieldClick(sender: UIButton) {
        if game.currentPlayer == Player.Black {return}
        if game.logic.getResult(game.currentBoard).finished {return}
        
        let (x, y) = getFieldCoords(sender)
        
        if currentTargets {
            for target in currentTargets! {
                if x == target.0.0 && y == target.0.1 {
                    currentTargets = nil
                    userMove(target)
                    break
                }
            }
        } else {
            var targets = game.logic.getTargetFieldsOnBoard(game.currentBoard, forPlayer: game.currentPlayer, forSourceX: x, andSourceY: y)
            if (targets.isEmpty) {
                if GameLogicHelper.getAllMovesOnBoard(game.currentBoard, logic: game.logic, forPlayer: game.currentPlayer).isEmpty {
                    // add empty dummy move if there is no real move
                    let dummyMove = ((x, y), Array<((Int, Int), ReversiPiece)>())
                    targets += dummyMove
                }
            }
            println("\(x) \(y)")
            println(targets)
            if (!targets.isEmpty) {
                currentTargets = targets
                refreshUI()
            }
        }
    }
    
    private func userMove(move: ((Int, Int), Array<((Int, Int), MyPiece)>)) {
        game.currentBoard.applyChanges(move.1)
        game.currentPlayer = game.currentPlayer.opponent()
        println(game.logic.evaluateBoard(game.currentBoard))
        refreshUI()
        
        aiMove()
    }
    
    private func aiMove() {
        if game.logic.getResult(game.currentBoard).finished {return}
        let globalQueuePriority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(globalQueuePriority, 0)) {
            let nextMove = self.ai.getNextMove(self.game)
            self.game.currentBoard.applyChanges(nextMove.1)
            
            dispatch_async(dispatch_get_main_queue()) {
                println(nextMove)
                println(self.game.logic.evaluateBoard(self.game.currentBoard))
                self.game.currentPlayer = self.game.currentPlayer.opponent()
                self.refreshUI()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refreshUI()
    }
    
    private func refreshUI() {
        // outlet collection would probably be nicer, but in Xcode 6 beta 4 there are problems with it!
        // TODO: use tags!
        for view in self.view.subviews {
            if let field = view as? UIButton {
                let (x, y) = getFieldCoords(field)
                if (x+y) % 2 == 0 {
                    field.backgroundColor = UIColor.whiteColor()
                }
                
                field.selected = false
                if let targets = currentTargets {
                    for target in targets {
                        if x == target.0.0 && y == target.0.1 {
                            field.selected = true
                        }
                    }
                }

                field.setTitle(game.currentBoard[x, y].toRaw(), forState: .Normal)
            }
        }
        
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
    
    private func getFieldCoords(field: UIButton) -> (Int, Int) {
        let x = Int((field.frame.origin.x - firstBoardField.frame.origin.x) / field.frame.size.width)
        let y = Int((field.frame.origin.y - firstBoardField.frame.origin.y) / field.frame.size.height)
        return (x, y)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

