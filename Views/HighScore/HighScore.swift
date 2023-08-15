//
//  HighScore.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture
import Foundation

struct HighScore: Reducer {
    struct State: Equatable {
        var scores: [Score] = []
    }
    
    enum Action: Equatable {
        case loadHighScores
        case didLoadHighScores([Score])
        case addScore(Score)
    }
    
    @Dependency(\.highScoreManager) private var highScoreManager
            
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadHighScores:
            return .run { send in
                await send(.didLoadHighScores(await highScoreManager.getHighScores()))
            }
        case let .didLoadHighScores(scores):
            state.scores = scores
            return .none
        case let .addScore(score):
            return .run { send in
                await highScoreManager.addScore(score)
                await send(.loadHighScores)
            }
        }
    }
}
