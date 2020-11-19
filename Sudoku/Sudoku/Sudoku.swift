//
//  Sudoku.swift
//  Sudoku
//
//  Created by Battlefield Duck on 15/11/2020.
//  Copyright © 2020 190189768. All rights reserved.
//

import UIKit

class Sudoku {
    var currentCell = 0
    
    // Define number of cells
    let numberOfCells = 81
    
    var topLeftCells, topRightCells, bottomLeftCells, bottomRightCells, answerCells, questionCells: [Int]!
    
    // Initalize the each square corner positions
    init() {
        topLeftCells = [0, 3, 6, 27, 30, 33, 54, 57, 60]
        topRightCells = topLeftCells.map { return $0 + 2 }
        bottomLeftCells = topRightCells.map { return $0 + 16 }
        bottomRightCells = bottomLeftCells.map { return $0 + 2 }
    }
    
    // Generate a new game
    func generateNewGame() {
        generateAnswerCells()
        generateQuestionCells()
    }
    
    // Reset currentCell to prepare backtracking
    func prepareBacktracking() {
        currentCell = 0
    }
    
    // Backtracking - Run inside a loop
    func backtrackingWithStep(cells: inout [Int]) -> Bool {
        if currentCell > (numberOfCells - 1) || currentCell < 0 { return false }
        
        // Skip all cells that is part of the question
        while questionCells[currentCell] != 0 {
            currentCell += 1
            if currentCell > (numberOfCells - 1) { return false }
        }
        
        // Move to next cell if the cell is valid
        if cells[currentCell] != 0 && isValid(cells: cells) {
            currentCell += 1
            if currentCell > (numberOfCells - 1) { return false }
            return true
        }
        
        // Add the cell by 1
        if cells[currentCell] < 9 {
            cells[currentCell] += 1
            return true
        }
        
        // if the cell reach 9, set current cell to 0, and start backtracking until meet a cells < 9 then add 1 on it
        repeat {
            cells[currentCell] = questionCells[currentCell] == 0 ? 0 : cells[currentCell]
            currentCell -= 1
            if currentCell < 0 { return false } // if cell < 0, it means it doesn't have any solution
        } while questionCells[currentCell] != 0 || (cells[currentCell] >= 9 && questionCells[currentCell] == 0)
        cells[currentCell] += 1
        return true
    }
    
    // Check is the Sudoku valid
    func isValid(cells: [Int]) -> Bool {
        let cells = getValidCells(cells: cells)

        for i in 0..<9 {
            // Check horizontal
            var horizontal = cells[i*9..<i*9+9]
            horizontal.removeAll(where: { $0 == 0 }) // ignore empty cells
            if Array(Set(horizontal)).count != horizontal.count { // Check is number unique
                return false
            }
            
            // Check vertical
            var vertical = [Int]()
            for j in 0..<9 {
                vertical.append(cells[i+j*9])
            }
            vertical.removeAll(where: { $0 == 0 }) // ignore empty cells
            if Array(Set(vertical)).count != vertical.count { // Check is number unique
                return false
            }
            
            // Check square
            var square = [Int]()
            for j in 0..<3 {
                square.append(cells[topLeftCells[i]+j*9])
                square.append(cells[topLeftCells[i]+j*9+1])
                square.append(cells[topLeftCells[i]+j*9+2])
            }
            square.removeAll(where: { $0 == 0 }) // ignore empty cells
            if Array(Set(square)).count != square.count { // Check is number unique
                return false
            }
        }
        
        return true
    }
    
    
    // Generate sudoku answer
    private func generateAnswerCells() {
        // Generate sudoku question until it has a solution
        while true {
            if let solution = getSolution(cells: getCells(numberOfCells: Int(Double(numberOfCells)/3))) {
                answerCells = solution
                break
            }
        }
    }
    
    // Check the sudoku has any solution. If yes, return answer. If not, return nil
    private func getSolution(cells: [Int]) -> [Int]? {
        var cells = cells
        questionCells = cells
        
        prepareBacktracking()
        while cells.contains(0) || !isValid(cells: cells) {
            if !backtrackingWithStep(cells: &cells) {
                return nil
            }
        }
        
        return cells
    }
    
    // Generate a random sudoku question
    private func getCells(numberOfCells: Int) -> [Int] {
        var cells = [Int]()
        
        while cells.count < numberOfCells {
            let row = [Int](1...9).shuffled()
            cells.append(contentsOf: row)
            
            if (!isValid(cells: cells)) {
                cells.removeLast(row.count)
            }
        }
        
        return getValidCells(cells: cells)
    }
    
    // Generate sudoku question base on the answer, it hide 5 cells on each square
    private func generateQuestionCells() {
        var cells: [Int] = answerCells
        
        for i in 0..<9 {
            let shouldHide = ([Int](repeating: 0, count: 5) + [Int](repeating: 1, count: 4)).shuffled()
            for j in 0..<3 {
                cells[topLeftCells[i]+j*9] = shouldHide[j*3] == 0 ? 0 : cells[topLeftCells[i]+j*9]
                cells[topLeftCells[i]+j*9+1] = shouldHide[j*3+1] == 0 ? 0 : cells[topLeftCells[i]+j*9+1]
                cells[topLeftCells[i]+j*9+2] = shouldHide[j*3+2] == 0 ? 0 : cells[topLeftCells[i]+j*9+2]
            }
        }
        
        questionCells = cells
    }
    
    // Fill the valid cells to size 81
    private func getValidCells(cells: [Int]) -> [Int] {
        var cells = cells
        cells.append(contentsOf: [Int](repeating: 0, count: (numberOfCells - cells.count)))
        return cells
    }
}
