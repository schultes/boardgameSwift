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
    
    @IBOutlet weak var firstBoardField: UIButton!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var aiSearchDepthLabel: UILabel!
    @IBOutlet weak var aiSearchDepthSlider: UISlider!
    @IBOutlet weak var restartButton: UIButton!
    @IBOutlet weak var gameSelectionControl: UISegmentedControl!
    var fields = [[UIButton?]]()
    var uiDisabled = false
    var game : Game = GenericGame<ReversiPiece, ReversiGameLogic>(logic: ReversiGameLogic())
    
    
    @IBAction func aiSearchDepthChanged(sender: UISlider) {
        let searchDepth = Int(sender.value)
        aiSearchDepthLabel.text = "KI-Suchtiefe: \(searchDepth)"
        game.aiSetSearchDepth(searchDepth)
    }
    
    
    @IBAction func restart() {
        game.restart()
        refreshUI()
    }
    
    @IBAction func gameSelected(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            game = GenericGame<ReversiPiece, ReversiGameLogic>(logic: ReversiGameLogic())
        } else {
            game = GenericGame<CheckersPiece, CheckersGameLogic>(logic: CheckersGameLogic())
        }
        refreshUI()
    }
    
    @IBAction func fieldClick(sender: UIButton) {
        if (uiDisabled) {return}
        let coords = getFieldCoords(sender)
        println(coords)
        if game.userActionAt(coords) {
            refreshUI()
            if (!game.isCurrentPlayerWhite) {aiMove()}
        }
    }
    
    private func aiMove() {
        disableUI(true)
        let globalQueuePriority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(globalQueuePriority, 0)) {
            let somethingChanged = self.game.aiMove()
            
            dispatch_async(dispatch_get_main_queue()) {
                if somethingChanged {self.refreshUI()}
                self.disableUI(false)
            }
        }
    }
    
    private func disableUI(disable: Bool) {
        uiDisabled = disable
        aiSearchDepthSlider.enabled = !disable
        restartButton.enabled = !disable
        gameSelectionControl.enabled = !disable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFields()
        refreshUI()
    }
    
    private func initFields() {
        // outlet collection would probably be nicer, but in Xcode 6 beta 4 there are problems with it!
        for _ in 0..<BOARD_SIZE {
            fields.append([UIButton?](count: BOARD_SIZE, repeatedValue: nil))
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
                    field.setTitle(game.getFieldAsStringAt((x, y)), forState: .Normal)
                }
            }
        }
        
        // set selected state
        for target in game.getCurrentTargets() {
            if let field = fields[target.x][target.y] {
                field.selected = true
            }
        }
        
        // update state label
        let result = game.result
        if result.finished {
            if let winner = result.winner {
                let player = winner == Player.White ? "Weiß" : "Schwarz"
                stateLabel.text = player + " gewinnt"
            } else {
                stateLabel.text = "Unentschieden"
            }
        } else {
            let player = game.isCurrentPlayerWhite ? "Weiß" : "Schwarz"
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

