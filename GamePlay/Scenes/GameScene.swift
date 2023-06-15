//
//  GameScene.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture
import SpriteKit

final class GameScene: SKScene {

    private let store: StoreOf<Root>
    private lazy var boardNode = BoardNode(size: size, store: store)
        
    init(size: CGSize, store: StoreOf<Root>) {
        self.store = store
        super.init(size: size)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        boardNode.anchorPoint = .zero
        boardNode.position = .zero
        addChild(boardNode)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard isUserInteractionEnabled else { return }
        touches.first.flatMap { boardNode.handleTouch($0) }
    }
}
