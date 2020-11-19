//
//  ViewController.swift
//  Sudoku
//
//  Created by Battlefield Duck on 13/11/2020.
//  Copyright © 2020 190189768. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let numberOfGrids = 81

//
//  Best experience in iPhone 11 Pro Max
//

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var sudokuGrids: UICollectionView!
    @IBOutlet weak var inputGrids: UICollectionView!
    @IBOutlet weak var restartButton: UIBarButtonItem!
    @IBOutlet weak var newButton: UIBarButtonItem!
    @IBOutlet weak var generateAnswerButton: UIButton!
    @IBOutlet weak var checkAnswerButton: UIButton!
    @IBOutlet weak var speedGlider: UISlider!
    
    var sudoku = Sudoku()
    var cells: [Int]!
    var selectedCell = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set up sudoku 9x9 grids
        sudokuGrids.delegate = self
        sudokuGrids.dataSource = self
        sudokuGrids.register(SudokuCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        sudokuGrids.isScrollEnabled = false
        
        // Set up user input grids
        inputGrids.delegate = self
        inputGrids.dataSource = self
        inputGrids.register(InputCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        inputGrids.isScrollEnabled = false
        
        // Generate a new game
        sudoku.generateNewGame()
        
        // Store the question to sudoku 9x9 grids dataSource
        cells = sudoku.questionCells
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowAnswer" {
            if let destination = segue.destination as? AnswerViewController {
                // Send the questionCells and answer to AnswerViewController
                destination.questionCells = sudoku.questionCells
                destination.cells = sudoku.answerCells
            }
        }
    }
    
    // A function to enable/disable UI easily
    func setUI(enable: Bool) {
        selectedCell = enable ? selectedCell : -1
        restartButton.isEnabled = enable
        newButton.isEnabled = enable
        generateAnswerButton.isEnabled = enable
        checkAnswerButton.isEnabled = enable
        inputGrids.isUserInteractionEnabled = enable
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseOut, animations: {
            self.inputGrids.alpha = enable ? 1.0 : 0.3
        }, completion: nil)
    }
    
    // Restart Button on click - Apply the question to cell again
    @IBAction func restartButtonOnClick(_ sender: Any) {
        cells = sudoku.questionCells
        sudokuGrids.reloadData()
    }

    // Generate Answer on click - Start backtracking
    @IBAction func generateAnswerOnClick(_ sender: Any) {
        setUI(enable: false)
        cells = sudoku.questionCells
        DispatchQueue.global(qos: .background).async {
            var sleepTime: UInt32 = 0
            self.sudoku.prepareBacktracking()
            while self.cells.contains(0) || !self.sudoku.isValid(cells: self.cells) {
                _ = self.sudoku.backtrackingWithStep(cells: &self.cells)
                DispatchQueue.main.async {
                    self.sudokuGrids.reloadData()
                    sleepTime = UInt32(self.speedGlider.maximumValue - self.speedGlider.value)
                }
                usleep(sleepTime)
            }
            DispatchQueue.main.async {
                self.setUI(enable: true)
            }
        }
    }
    
    // Check Answer on click
    @IBAction func checkAnswerOnClick(_ sender: Any) {
        // If correct, show Congratulations alert
        if !self.cells.contains(0) && sudoku.isValid(cells: cells) {
            let alert = UIAlertController(title: "Congratulations", message: "Your answer is correct", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Nice", style: .default))
            present(alert, animated: true)
        }
        // If incorrect, show Oops alert. If "View answer" button clicked, performSegue ShowAnswer.
        else {
            let alert = UIAlertController(title: "Oops", message: "Your answer is incorrect", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "View answer", style: .default) { (_) in
                self.performSegue(withIdentifier: "ShowAnswer", sender: nil)
            })
            alert.addAction(UIAlertAction(title: "Continue", style: .default))
            present(alert, animated: true)
        }
    }
    
    // New on click - Generate a new sudoku game
    @IBAction func newGameOnClick(_ sender: Any) {
        setUI(enable: false)
        DispatchQueue.global(qos: .background).async {
            self.sudoku.generateNewGame()
            self.cells = self.sudoku.questionCells
            DispatchQueue.main.async {
                self.sudokuGrids.reloadData()
                UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
                    self.sudokuGrids.alpha = 1.0
                }, completion: nil)
                self.setUI(enable: true)
            }
        }
        UIView.animate(withDuration: 1.0, delay: 0.0, options: .curveEaseOut, animations: {
            self.sudokuGrids.alpha = 0.0
        }, completion: nil)
    }
    
    // Number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == inputGrids ? 10 : numberOfGrids
    }
    
    // Style of cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == inputGrids {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! InputCollectionViewCell
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 3
            cell.label.text = indexPath.item == 0 ? "" : "\(indexPath.item)"
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SudokuCollectionViewCell
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = selectedCell == indexPath.item ? 2 : 1
        cell.backgroundColor = sudoku.questionCells[indexPath.item] == 0 ? UIColor.white : UIColor.init(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0)
        cell.label.textColor = !generateAnswerButton.isEnabled && sudoku.questionCells[indexPath.item] == 0 ? UIColor.red : UIColor.black
        
        // Set cell value, if it is 0 then empty
        cell.label.text = cells[indexPath.item] == 0 ? "" : "\(cells[indexPath.item])"
        
        // Set rounded corner direction
        if (sudoku.topLeftCells.contains(indexPath.item)) {
            cell.layer.maskedCorners = .layerMinXMinYCorner
        } else if (sudoku.topRightCells.contains(indexPath.item)) {
            cell.layer.maskedCorners = .layerMaxXMinYCorner
        } else if (sudoku.bottomLeftCells.contains(indexPath.item)) {
            cell.layer.maskedCorners = .layerMinXMaxYCorner
        } else if (sudoku.bottomRightCells.contains(indexPath.item)) {
            cell.layer.maskedCorners = .layerMaxXMaxYCorner
        }
        
        // Set corner radius when it is the corner of square
        cell.layer.cornerRadius = cell.layer.maskedCorners.rawValue == 15 ? 0 : 10
        
        return cell
    }
    
    // Cell on click
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == sudokuGrids {
            // If the cell is not part of the question, set selectedCell and update UI
            if sudoku.questionCells[indexPath.item] == 0 {
                selectedCell = indexPath.item
                sudokuGrids.reloadData()
            }
        } else if collectionView == inputGrids {
            // If selectedCell is valid, set the selected cell to the input number and update UI
            if selectedCell != -1 {
                cells[selectedCell] = indexPath.item
                sudokuGrids.reloadData()
            }
        }
    }
}
