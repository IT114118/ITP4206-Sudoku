//
//  AnswerViewController.swift
//  Sudoku
//
//  Created by Battlefield Duck on 17/11/2020.
//  Copyright © 2020 190189768. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"
private let numberOfGrids = 81

class AnswerViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    @IBOutlet weak var sudokuGrids: UICollectionView!
    
    var questionCells: [Int]!
    var cells: [Int]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sudokuGrids.delegate = self
        sudokuGrids.dataSource = self
        sudokuGrids.register(SudokuCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        sudokuGrids.isScrollEnabled = false
    }
    
    // Number of cells
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfGrids
    }
    
    // Style of cells
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SudokuCollectionViewCell
        
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1
        cell.backgroundColor = questionCells[indexPath.item] == 0 ? UIColor.white : UIColor.init(red: 222/255, green: 222/255, blue: 222/255, alpha: 1.0)
        cell.label.textColor = questionCells[indexPath.item] == 0 ? UIColor.red : UIColor.black
        
        // Set cell value, if it is 0 then empty
        cell.label.text = cells[indexPath.item] == 0 ? "" : "\(cells[indexPath.item])"
        
        // Set rounded corner direction
        let sudoku = Sudoku()
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
}
