//
//  HighScoreManager.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import Dependencies
import Foundation

struct HighScoreManager {
    var getHighScores: @Sendable () async -> [Score]
    var addScore: @Sendable (Score) async -> Void
}

extension DependencyValues {
    var highScoreManager: HighScoreManager {
        get { self[HighScoreManager.self] }
        set { self[HighScoreManager.self] = newValue }
    }
}

extension HighScoreManager: DependencyKey {
    static var liveValue: HighScoreManager {
        let storage = HighScoreStorage()
        return Self(
            getHighScores: { await storage.scores },
            addScore: { await storage.addScore($0) }
        )
    }
}

// MARK: implementation

private final actor HighScoreStorage {
    private lazy var defaults = UserDefaults(suiteName: "com.tiennv166.line.highscores")
    private lazy var key = "scores"
    private lazy var limit = 16
    
    var scores: [Score] {
        guard let data = defaults?.data(forKey: key) else { return defaultScores }
        return (try? JSONDecoder().decode([Score].self, from: data)) ?? defaultScores
    }
    
    func addScore(_ score: Score) {
        let scores = (self.scores + [score]).sorted { $0.score > $1.score }
        let newScores = Array(scores.prefix(limit))
        guard let data = try? JSONEncoder().encode(newScores) else { return }
        defaults?.set(data, forKey: key)
    }
    
    private var defaultScores: [Score] {
        [
            Score(playerName: "Thor", score: 100),
            Score(playerName: "Loki", score: 116),
            Score(playerName: "Thor", score: 120)
        ]
    }
}
