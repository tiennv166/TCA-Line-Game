//
//  HighScore.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture
import Foundation

struct HighScore: ReducerProtocol {
    struct State: Equatable {
        var scores: [Score] = []
    }
    
    enum Action: Equatable {
        case loadHighScores
        case didLoadHighScores([Score])
        case addScore(Score)
    }
    
    @Dependency(\.highScoreManager) var highScoreManager
            
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadHighScores:
            return .task {
                return .didLoadHighScores(await highScoreManager.getHighScores())
            }
        case let .didLoadHighScores(scores):
            state.scores = scores
            return .none
        case let .addScore(score):
            return .task {
                await highScoreManager.addScore(score)
                return .loadHighScores
            }
        }
    }
}
