//
//  BallNode.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import SpriteKit

final class BallNode: SKSpriteNode {

    let ballColor: BallColor
    let gridPosition: GridPosition

    init(ballColor: BallColor, gridPosition: GridPosition, size: CGSize) {
        self.ballColor = ballColor
        self.gridPosition = gridPosition
        let texture = SKTexture(imageNamed: ballColor.imageNamed)
        super.init(texture: texture, color: .clear, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
