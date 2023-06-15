//
//  Game.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture

struct Game: ReducerProtocol, Sendable {
    struct State: Equatable {
        var scoreBoard: GameStorable = GameStorable(score: 0, board: Board(balls: [], nextBalls: []))
        var targetPosition: GridPosition?
        var selectedBall: Ball?
        var scoringBalls: [Ball] = []
        var undoStack: [GameStorable] = []
    }
    
    enum Action: Equatable, Sendable {
        case cellTapped(GridPosition)
        case didMoveSelectedBallToTargetPosition
        case didClearAllScoringBalls
        case undo
        case createNewGame
        case loadGame
        case saveGame
        case didLoadGame(GameStorable)
        case didSaveGame
    }
    
    @Dependency(\.gameStorage) var gameStorage
            
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case let .cellTapped(position):
            if let ball = state.board.ball(in: position) {
                state.selectedBall = ball
                state.targetPosition = nil
                return .none
            }
            state.targetPosition = position
            return .none
        case .didMoveSelectedBallToTargetPosition:
            guard let selected = state.selectedBall else { return .none }
            guard let position = state.targetPosition else { return .none }
            state.undoStack.append(state.scoreBoard)
            if state.undoStack.count > undoStackLimit {
                state.undoStack.removeFirst()
            }
            let oldBalls = state.board.balls.map { (selected == $0) ? $0.updatePosition(position) : $0 }
            state.selectedBall = nil
            state.targetPosition = nil
            let selectedBall = selected.updatePosition(position)
            let scoringBalls = Board.getScoringBalls(around: selectedBall, in: oldBalls)
            if !scoringBalls.isEmpty {
                state.scoreBoard.board = Board(balls: oldBalls, nextBalls: state.scoreBoard.board.nextBalls)
                state.scoringBalls = {
                    // Move the selected ball to the first position
                    [selectedBall] + scoringBalls.filter { $0 != selectedBall }
                }()
            } else {
                let newBalls: [Ball] = {
                    let nextBalls = state.board.nextBalls
                    guard let conflict = (nextBalls.first { $0.gridPosition == position }) else { return nextBalls }
                    let balls = nextBalls.filter { $0 != conflict }
                    return balls + Board
                        .generateRandomBalls(1, excepts: balls + oldBalls)
                        .map { $0.updateColor(conflict.color) }
                }()
                let balls = oldBalls + newBalls
                let nextBalls = Board.generateRandomBalls(3, excepts: balls)
                state.scoreBoard.board = Board(balls: balls, nextBalls: nextBalls)
                // Check to get scoring balls with new balls
                state.scoringBalls = {
                    let result = Array(Set(newBalls.flatMap { Board.getScoringBalls(around: $0, in: balls) }))
                    if !result.contains(selectedBall) { return result }
                    // Move the selected ball to the first position
                    return [selectedBall] + result.filter { $0 != selectedBall }
                }()
            }
            return .send(.saveGame)
        case .didClearAllScoringBalls:
            let scoringBalls = state.scoringBalls
            guard !scoringBalls.isEmpty else { return .none }
            let balls = Array(Set(state.board.balls).subtracting(Set(scoringBalls)))
            state.scoreBoard.board = Board(balls: balls, nextBalls: state.board.nextBalls)
            state.scoreBoard.score += Board.getScore(numOfBalls: scoringBalls.count)
            state.selectedBall = nil
            state.targetPosition = nil
            state.scoringBalls = []
            return .send(.saveGame)
        case .undo:
            guard let last = state.undoStack.last else { return .none }
            state.selectedBall = nil
            state.targetPosition = nil
            state.scoreBoard = last
            state.scoringBalls = []
            state.undoStack.removeLast()
            return .send(.saveGame)
        case .createNewGame:
            let newState = State()
            state.selectedBall = newState.selectedBall
            state.scoreBoard = GameStorable(score: 0, board: Board.random)
            state.targetPosition = newState.targetPosition
            state.scoringBalls = newState.scoringBalls
            state.undoStack = newState.undoStack
            return .send(.saveGame)
        case .loadGame:
            return .task {
                if let game = await gameStorage.loadGame() {
                    return .didLoadGame(game)
                }
                return .createNewGame
            }
        case .saveGame:
            return .task { [game = state.scoreBoard] in
                await gameStorage.saveGame(game)
                return .didSaveGame
            }
        case let .didLoadGame(game):
            state.scoreBoard = game
            state.selectedBall = nil
            state.targetPosition = nil
            state.scoringBalls = []
            state.undoStack = []
            return .none
        case .didSaveGame:
            return .none
        }
    }
}

extension Game.State {
    var score: Int { scoreBoard.score }
    var board: Board { scoreBoard.board }
    var isGameOver: Bool { board.isGameOver && scoringBalls.isEmpty }
    var canUndo: Bool { !undoStack.isEmpty }
}

private let undoStackLimit = 20
