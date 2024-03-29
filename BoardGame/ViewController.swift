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
    var game : Game = GenericGame<ReversiGameLogic>(logic: ReversiGameLogic())
    
    
    @IBAction func aiSearchDepthChanged(_ sender: UISlider) {
        let searchDepth = Int(sender.value)
        aiSearchDepthLabel.text = "KI-Suchtiefe: \(searchDepth)"
        game.aiSetSearchDepth(searchDepth)
    }
    
    
    @IBAction func restart() {
        game.restart()
        refreshUI()
    }
    
    @IBAction func gameSelected(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            game = GenericGame<ReversiGameLogic>(logic: ReversiGameLogic())
        case 1:
            game = GenericGame<CheckersGameLogic>(logic: CheckersGameLogic())
        default:
            game = GenericGame<ChessGameLogic>(logic: ChessGameLogic())
        }
        refreshUI()
    }
    
    @IBAction func fieldClick(_ sender: UIButton) {
        if (uiDisabled) {return}
        let coords = getCoords(ofField: sender)
        print(coords)
        if game.userAction(atCoords: coords) {
            refreshUI()
            if (!game.isCurrentPlayerWhite) {aiMove()}
        }
    }
    
    private func aiMove() {
        disableUI(true)
        game.aiMove {
            self.refreshUI()
            self.disableUI(false)
        }
    }
    
    private func disableUI(_ disable: Bool) {
        uiDisabled = disable
        aiSearchDepthSlider.isEnabled = !disable
        restartButton.isEnabled = !disable
        gameSelectionControl.isEnabled = !disable
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initFields()
        refreshUI()
    }
    
    private func initFields() {
        // outlet collection would probably be nicer, but in Xcode 6 beta 4 there are problems with it!
        for _ in 0..<BOARD_SIZE {
            fields.append([UIButton?](repeating: nil, count: BOARD_SIZE))
        }
        for view in self.view.subviews {
            if let field = view as? UIButton {
                if field.tag != 1 {continue}
                let (x, y) = getCoords(ofField: field)
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
                        field.backgroundColor = UIColor.white
                    }
                    field.isSelected = false
                    field.setTitle(game.getFieldAsString(atCoords: (x, y)), for: UIControl.State())
                }
            }
        }
        
        // set selected state
        for target in game.getCurrentTargets() {
            if let field = fields[target.x][target.y] {
                field.isSelected = true
            }
        }
        
        // update state label
        let result = game.result
        if result.finished {
            if let winner = result.winner {
                let player = winner == Player.white ? "Weiß" : "Schwarz"
                stateLabel.text = player + " gewinnt"
            } else {
                stateLabel.text = "Unentschieden"
            }
        } else {
            let player = game.isCurrentPlayerWhite ? "Weiß" : "Schwarz"
            stateLabel.text = player + " am Zug"
        }
    }
    
    private func getCoords(ofField field: UIButton) -> Coords {
        let size = firstBoardField.frame.size
        let x = Int((field.frame.midX - firstBoardField.frame.origin.x) / size.width)
        let y = Int((field.frame.midY - firstBoardField.frame.origin.y) / size.height)
        return (x, y)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

