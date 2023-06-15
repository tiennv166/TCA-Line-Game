//
//  AudioPlayer.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import AVFoundation
import Dependencies

// MARK: AudioType

enum AudioType {
    case block, moving, explosion, gameover
}

// MARK: AudioPlayer

struct AudioPlayer {
    var playVibration: () -> Void
    var play: (AudioType) -> Void
}

extension DependencyValues {
    var audioPlayer: AudioPlayer {
        get { self[AudioPlayer.self] }
        set { self[AudioPlayer.self] = newValue }
    }
}

extension AudioPlayer: DependencyKey {
    static var liveValue: AudioPlayer {
        let player = _AudioPlayer()
        return Self(
            playVibration: { player.playVibration() },
            play: { player.play($0) }
        )
    }
}

// MARK: implementation

private final class _AudioPlayer {
    
    private var player: AVAudioPlayer?
    
    func playVibration() {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
    }
    
    func play(_ type: AudioType) {
        guard let url = type.url else { return }
        DispatchQueue.global(qos: .default).async {
            self.player?.stop()
            self.player = try? AVAudioPlayer(contentsOf: url)
            self.player?.play()
        }
    }
}

private extension AudioType {
    var fileName: String {
        switch self {
        case .block: return "block"
        case .moving: return "moving"
        case .explosion: return "explosion"
        case .gameover: return "gameover"
        }
    }

    var fileExtension: String {
        switch self {
        case .block, .explosion, .gameover: return "mp3"
        case .moving: return "caf"
        }
    }
    
    var url: URL? { Bundle.main.url(forResource: fileName, withExtension: fileExtension) }
}
