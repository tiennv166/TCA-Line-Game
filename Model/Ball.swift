//
//  Ball.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import Foundation

struct Ball: Hashable, Codable {
    let xPos: Int32
    let yPos: Int32
    let color: BallColor

    init(xPos: Int32, yPos: Int32, color: BallColor) {
        self.xPos = xPos
        self.yPos = yPos
        self.color = color
    }
}

extension Ball: Identifiable {
    var id: Int { cellIndex }
}

extension Ball {
    var gridPosition: GridPosition { GridPosition(xPos, yPos) }
    var cellIndex: Int { Int(yPos) * Board.dimensions + Int(xPos) }
    
    func updatePosition(_ position: GridPosition) -> Ball {
        Ball(xPos: position.x, yPos: position.y, color: color)
    }
    
    func updateColor(_ newColor: BallColor) -> Ball {
        Ball(xPos: xPos, yPos: yPos, color: newColor)
    }
}
