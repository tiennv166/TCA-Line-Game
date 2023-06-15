//
//  BoardNode.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import Combine
import ComposableArchitecture
import SpriteKit

final class BoardNode: SKSpriteNode {

    private let store: StoreOf<Root>
    private let gameStore: ViewStore<Game.State, Game.Action>
    private let settingsStore: ViewStore<Settings.State, Settings.Action>
    private var cancellables: Set<AnyCancellable> = []
    
    @Dependency(\.audioPlayer) private var audioPlayer

    /// The nodes are arranged in a 2D array (an array with rows and columns)
    private var boardCellNodes: [GridPosition: BoardCellNode] = [:]
    
    /// Current selected ball
    private var selectedBallNode: BallNode?
    
    private var isTouchEnabled: Bool = true
    private var isSoundEnabled: Bool = false
    
    init(size: CGSize, store: StoreOf<Root>) {
        self.store = store
        self.gameStore = ViewStore(store.scope(state: \.game, action: Root.Action.game))
        self.settingsStore = ViewStore(store.scope(state: \.settings, action: Root.Action.settings))
        let texture = SKTexture(imageNamed: "sceneBg")
        super.init(texture: texture, color: .clear, size: size)
        configure(size: size)
        configureStores()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure(size: CGSize) {
        let nodeSize = size.width
        let node = SKSpriteNode()
        node.size = size
        node.anchorPoint = CGPoint.zero
        node.position = CGPoint(x: 0, y: size.height / 2 - nodeSize / 2)
        addChild(node)

        // Cell node in graph parent node
        let cellSize = nodeSize / CGFloat(Board.dimensions)
        let numberOfCell = Board.dimensions * Board.dimensions
        for cellIdx in 0..<numberOfCell {
            // Get the position of the maze node.
            let x = cellIdx % Board.dimensions
            let y = cellIdx / Board.dimensions
            // Create cell node
            let gridPosition = GridPosition(x: Int32(x), y: Int32(y))
            let cellNode = BoardCellNode(
                gridPosition: gridPosition,
                size: CGSize(width: cellSize, height: cellSize)
            )
            cellNode.anchorPoint = .zero
            cellNode.position = CGPoint(x: CGFloat(x) * cellSize, y: CGFloat(y) * cellSize)
            cellNode.zPosition = 1
            // Add the cell sprite node to the cell's parent node.
            node.addChild(cellNode)
            // Add the cell sprite node to the 2D array of sprite nodes so we
            // can reference it later.
            boardCellNodes[gridPosition] = cellNode
        }
    }
    
    private func configureStores() {
        Publishers
            .CombineLatest(
                gameStore.publisher,
                settingsStore.publisher.map { $0.isNextBallsHidden }.removeDuplicates()
            )
            .sink { [weak self] in self?.update(game: $0.0, isNextBallsHidden: $0.1) }
            .store(in: &cancellables)
        
        settingsStore.publisher.map { $0.isSoundEnabled }.removeDuplicates()
            .assign(to: \.isSoundEnabled, on: self)
            .store(in: &cancellables)
    }
    
    private func update(game: Game.State, isNextBallsHidden: Bool) {
        // Need to improve here
        // It is necessary to update only the changes instead of recreating all nodes
        removeChildren(in: children.filter { $0 is BallNode })
        game.board.balls.forEach { ball in
            guard let boardCellNode = boardCellNodes[ball.gridPosition] else { return }
            let ballNode = BallNode(
                ballColor: ball.color,
                gridPosition: ball.gridPosition,
                size: boardCellNode.size
            )
            ballNode.anchorPoint = .zero
            ballNode.position = boardCellNode.position
            ballNode.zPosition = boardCellNode.zPosition + 2
            addChild(ballNode)
        }
        
        // Add next balls with small size
        let nextBalls = isNextBallsHidden ? [] : game.board.nextBalls
        nextBalls.forEach { ball in
            guard let boardCellNode = boardCellNodes[ball.gridPosition] else { return }
            let boardCellNodeSize = boardCellNode.size.width
            let smallBallSize = boardCellNodeSize * 0.5
            let offset = boardCellNodeSize / 2.0 - smallBallSize / 2.0
            let ballNode = BallNode(
                ballColor: ball.color,
                gridPosition: ball.gridPosition,
                size: CGSize(width: smallBallSize, height: smallBallSize)
            )
            ballNode.anchorPoint = .zero
            ballNode.position = CGPoint(
                x: boardCellNode.position.x + offset,
                y: boardCellNode.position.y + offset
            )
            ballNode.zPosition = boardCellNode.zPosition + 1
            addChild(ballNode)
        }
        
        if game.isGameOver {
            if isSoundEnabled {
                audioPlayer.play(.gameover)
            }
        } else if !game.scoringBalls.isEmpty {
            Task { await animateScoringBall(game.scoringBalls) }
        } else {
            selectedBallNode = children
                .compactMap { $0 as? BallNode }
                .first { game.selectedBall?.gridPosition == $0.gridPosition }
            
            if let targetPosition = game.targetPosition {
                Task { await animateMovingSelectedBall(to: targetPosition, in: game.board) }
            } else {
                stopAnimatingSelectedBall()
                animateSelectedBall()
            }
        }
    }
        
    func handleTouch(_ touch: UITouch) {
        guard isTouchEnabled else { return }
        switch atPoint(touch.location(in: self)) {
        case let boardCellNode as BoardCellNode:
            gameStore.send(.cellTapped(boardCellNode.gridPosition))
        case let ballNode as BallNode:
            gameStore.send(.cellTapped(ballNode.gridPosition))
        default:
            break
        }
    }
}

extension BoardNode {
    private func animateSelectedBall() {
        guard let selectedBallNode = selectedBallNode else { return }
        let originPosition = selectedBallNode.position
        let animatedPosition1 = CGPoint(x: originPosition.x, y: originPosition.y + 4)
        let animatedPosition2 = CGPoint(x: originPosition.x, y: originPosition.y - 4)
        let action = SKAction.sequence([
            SKAction.move(to: animatedPosition1, duration: 0.3),
            SKAction.wait(forDuration: 0.2),
            SKAction.move(to: animatedPosition2, duration: 0.3)
        ])
        selectedBallNode.run(.repeatForever(action))
    }
    
    private func stopAnimatingSelectedBall() {
        guard let selectedBallNode = selectedBallNode else { return }
        selectedBallNode.removeAllActions()
        guard let boardCellNode = boardCellNodes[selectedBallNode.gridPosition] else { return }
        selectedBallNode.position = boardCellNode.position
        selectedBallNode.size = boardCellNode.size
    }
    
    private func animateMovingSelectedBall(to position: GridPosition, in board: Board) async {
        guard let selectedBallNode = selectedBallNode else { return }
        guard board.ball(in: position) == nil else { return }
        let startPosition = selectedBallNode.gridPosition
        let path = board.findPath(from: startPosition, to: position)
        guard !path.isEmpty else {
            if isSoundEnabled {
                audioPlayer.play(.block)
            }
            audioPlayer.playVibration()
            return
        }
        if isSoundEnabled {
            audioPlayer.play(.moving)
        }
        stopAnimatingSelectedBall()
        let actions = path
            .compactMap { boardCellNodes[$0] }
            .map { SKAction.move(to: $0.position, duration: 0.04) }
        isTouchEnabled = false
        await selectedBallNode.run(.sequence(actions))
        gameStore.send(.didMoveSelectedBallToTargetPosition)
        isTouchEnabled = true
    }
    
    private func animateScoringBall(_ balls: [Ball]) async {
        isTouchEnabled = false
        let ballNodes = children.compactMap { $0 as? BallNode }
        let actionGroup: [SKNode: SKAction] = balls
            .map { ball -> [SKNode: SKAction] in
                guard let ballNode = (ballNodes.first { $0.gridPosition == ball.gridPosition }) else { return [:] }
                let originPos = ballNode.position
                let originSize = ballNode.size.width
                let finalSize = CGSize(width: originSize * 1.6, height: originSize * 1.6)
                let offSet = finalSize.width / 2.0 - originSize / 2.0
                let finalPos = CGPoint(x: originPos.x - offSet, y: originPos.y - offSet)
                let action = SKAction.sequence([
                    SKAction.group([
                        SKAction.fadeOut(withDuration: 0.3),
                        SKAction.scale(to: finalSize, duration: 0.3),
                        SKAction.move(to: finalPos, duration: 0.3)
                    ]),
                    SKAction.removeFromParent()
                ])
                return [ballNode: action]
            }
            .reduce([:]) { $0.merging($1) { $1 } }
        if isSoundEnabled {
            audioPlayer.play(.explosion)
        }
        await actionGroup.runParallel()
        gameStore.send(.didClearAllScoringBalls)
        isTouchEnabled = true
        await animateAddingNewScore(scoringBalls: balls)
    }
    
    private func animateAddingNewScore(scoringBalls: [Ball]) async {
        guard let firstBall = scoringBalls.first else { return }
        guard let boardCellNode = boardCellNodes[firstBall.gridPosition] else { return }
        let score = Board.getScore(numOfBalls: scoringBalls.count)
        guard score > 0 else { return }
        // Add score animation
        let boardCellSize = boardCellNode.size.width
        let scoreNode = SKLabelNode(text: "\(score)")
        scoreNode.fontName = "Copperplate-Bold"
        scoreNode.fontSize = 12.0
        scoreNode.fontColor = firstBall.color.toUiColor
        scoreNode.verticalAlignmentMode = .center
        scoreNode.horizontalAlignmentMode = .center
        scoreNode.position = CGPoint(
            x: boardCellNode.position.x + boardCellSize / 2.0,
            y: boardCellNode.position.y + boardCellSize / 2.0
        )
        scoreNode.zPosition = boardCellNode.zPosition + 3
        addChild(scoreNode)
        let action = SKAction.sequence([
            SKAction.scale(by: 4.5, duration: 0.3),
            SKAction.wait(forDuration: 0.15),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ])
        await scoreNode.run(action)
    }
}
