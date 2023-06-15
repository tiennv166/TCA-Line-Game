//
//  BoardCellNode.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import SpriteKit

final class BoardCellNode: SKSpriteNode {

    let gridPosition: GridPosition

    init(gridPosition: GridPosition, size: CGSize) {
        self.gridPosition = gridPosition
        let texture = SKTexture(imageNamed: "board_cell")
        super.init(texture: texture, color: .clear, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
