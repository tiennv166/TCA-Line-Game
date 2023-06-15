//
//  GameSettingsClient.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import Dependencies
import Foundation

struct GameSettingsClient {
    var isSoundEnabled: @Sendable () async -> Bool
    var setSoundEnabled: @Sendable (Bool) async -> Void
    var isNextBallsHidden: @Sendable () async -> Bool
    var setNextBallsHidden: @Sendable (Bool) async -> Void
}

extension DependencyValues {
    var settingsClient: GameSettingsClient {
        get { self[GameSettingsClient.self] }
        set { self[GameSettingsClient.self] = newValue }
    }
}

extension GameSettingsClient: DependencyKey {
    static var liveValue: GameSettingsClient {
        let storage = GameSettingsStorage()
        return Self(
            isSoundEnabled: { await storage.isSoundEnabled },
            setSoundEnabled: { await storage.setSoundEnabled($0) },
            isNextBallsHidden: { await storage.isNextBallsHidden },
            setNextBallsHidden: { await storage.setNextBallsHidden($0) }
        )
    }
}

// MARK: implementation

private final actor GameSettingsStorage {
    private lazy var defaults = UserDefaults(suiteName: "com.tiennv166.line.settings")
    private lazy var isSoundEnabledKey = "sound_enabled"
    private lazy var isNextBallsHiddenKey = "next_balls_hidden"
    
    var isSoundEnabled: Bool { defaults?.bool(forKey: isSoundEnabledKey) ?? true }
    func setSoundEnabled(_ enabled: Bool) {
        defaults?.set(enabled, forKey: isSoundEnabledKey)
    }

    var isNextBallsHidden: Bool { defaults?.bool(forKey: isNextBallsHiddenKey) ?? false }
    func setNextBallsHidden(_ hidden: Bool) {
        defaults?.set(hidden, forKey: isNextBallsHiddenKey)
    }
}
