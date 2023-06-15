//
//  GameStorageClient.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import Dependencies
import Foundation

struct GameStorageClient {
    var loadGame: @Sendable () async -> GameStorable?
    var saveGame: @Sendable (GameStorable) async -> Void
}

extension DependencyValues {
    var gameStorage: GameStorageClient {
        get { self[GameStorageClient.self] }
        set { self[GameStorageClient.self] = newValue }
    }
}

extension GameStorageClient: DependencyKey {
    static var liveValue: GameStorageClient {
        let storage = GameStorage()
        return Self(
            loadGame: { await storage.loadGame() },
            saveGame: { await storage.saveGame($0) }
        )
    }
}

// MARK: implementation

private final actor GameStorage {
    private lazy var defaults = UserDefaults(suiteName: "com.tiennv166.line.game.sate")
    private lazy var key = "current_game"
    
    func loadGame() -> GameStorable? {
        guard let data = defaults?.data(forKey: key) else { return nil }
        guard let game = (try? JSONDecoder().decode(GameStorable.self, from: data)) else { return nil }
        return game
    }
    
    func saveGame(_ game: GameStorable) {
        guard let data = try? JSONEncoder().encode(game) else { return }
        defaults?.set(data, forKey: key)
    }
}
