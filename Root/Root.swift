//
//  Root.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture
import Foundation

struct Root: Reducer {
    struct State: Equatable {
        var settings = Settings.State()
        var game = Game.State()
        var highScore = HighScore.State()
    }
    
    enum Action: Equatable {
        case settings(Settings.Action)
        case game(Game.Action)
        case highScore(HighScore.Action)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { _, _ in .none }
        Scope(state: \.settings, action: /Action.settings) { Settings() }
        Scope(state: \.game, action: /Action.game) { Game() }
        Scope(state: \.highScore, action: /Action.highScore) { HighScore() }
    }
}
