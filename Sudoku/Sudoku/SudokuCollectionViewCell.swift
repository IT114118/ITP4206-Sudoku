//
//  SudokuCollectionViewCell.swift
//  Sudoku
//
//  Created by Battlefield Duck on 15/11/2020.
//  Copyright © 2020 190189768. All rights reserved.
//

import UIKit

// Sudoku cells
class SudokuCollectionViewCell: UICollectionViewCell {
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Create a label on each cell
        let w = Double(UIScreen.main.bounds.size.width)
        label = UILabel(frame: CGRect(x: 0, y: 0, width: w / 9 - 8.5, height: w / 9 - 8.5))
        label.textAlignment = .center
        self.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("SudokuCollectionViewCell")
    }
}
