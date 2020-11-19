//
//  InputCollectionViewCell.swift
//  Sudoku
//
//  Created by Battlefield Duck on 17/11/2020.
//  Copyright © 2020 190189768. All rights reserved.
//

import UIKit

// Input Cells
class InputCollectionViewCell: UICollectionViewCell {
    var label: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Create a label on each cell
        label = UILabel(frame: CGRect(x: 0, y: 0, width: 45, height: 45))
        label.textAlignment = .center
        self.addSubview(label)
    }
    
    required init?(coder: NSCoder) {
        fatalError("InputCollectionViewCell")
    }
}
