//
//  Settings.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture
import Foundation

struct Settings: Reducer {
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
    
    @Dependency(\.settingsClient) private var settingsClient
            
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .loadSettings:
            return .run { send in
                var state = State()
                state.isSoundEnabled = await settingsClient.isSoundEnabled()
                state.isNextBallsHidden = await settingsClient.isNextBallsHidden()
                await send(.didLoadSettings(state))
            }
        case let .didLoadSettings(newState):
            state.isSoundEnabled = newState.isSoundEnabled
            state.isNextBallsHidden = newState.isNextBallsHidden
            return .none
        case .toggleSoundEnabaled:
            state.isSoundEnabled.toggle()
            return .run { [state] send in
                await settingsClient.setSoundEnabled(state.isSoundEnabled)
                await send(.didSave)
            }
        case .toggleNextBallsHidden:
            state.isNextBallsHidden.toggle()
            return .run { [state] send in
                await settingsClient.setNextBallsHidden(state.isNextBallsHidden)
                await send(.didSave)
            }
        case .didSave:
            return .none
        }
    }
}
