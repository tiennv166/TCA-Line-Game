//
//  Settings.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture
import Foundation

struct Settings: ReducerProtocol {
    struct State: Equatable {
        var isSoundEnabled: Bool = false
        var isNextBallsHidden: Bool = false
    }
    
    enum Action: Equatable {
        case loadSettings
        case didLoadSettings(State)
        case toggleSoundEnabaled
        case toggleNextBallsHidden
        case didSave
    }
    
    @Dependency(\.settingsClient) var settingsClient
            
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .loadSettings:
            return .task {
                var state = State()
                state.isSoundEnabled = await settingsClient.isSoundEnabled()
                state.isNextBallsHidden = await settingsClient.isNextBallsHidden()
                return .didLoadSettings(state)
            }
        case let .didLoadSettings(newState):
            state.isSoundEnabled = newState.isSoundEnabled
            state.isNextBallsHidden = newState.isNextBallsHidden
            return .none
        case .toggleSoundEnabaled:
            state.isSoundEnabled.toggle()
            return .task { [state] in
                await settingsClient.setSoundEnabled(state.isSoundEnabled)
                return .didSave
            }
        case .toggleNextBallsHidden:
            state.isNextBallsHidden.toggle()
            return .task { [state] in
                await settingsClient.setNextBallsHidden(state.isNextBallsHidden)
                return .didSave
            }
        case .didSave:
            return .none
        }
    }
}
