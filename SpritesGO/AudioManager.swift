import Foundation

#if os(iOS)
import AVFoundation
#endif

enum SpriteSound {
    case item
    case equip
    case treat
    case jump
    case spin
    case shower

    var fileName: String {
        switch self {
        case .item: return "item_chime"
        case .equip: return "equip_pop"
        case .treat: return "treat_bite"
        case .jump: return "jump_boing"
        case .spin: return "spin_twinkle"
        case .shower: return "shower_splash"
        }
    }
}

@MainActor
final class SpriteAudio {
    static let shared = SpriteAudio()

    #if os(iOS)
    private var musicPlayer: AVAudioPlayer?
    private var soundPlayers: [SpriteSound: AVAudioPlayer] = [:]
    #endif

    private init() {}

    func startMusic(volume: VolumeLevel) {
        #if os(iOS)
        configureSession()
        if musicPlayer == nil {
            guard let url = Bundle.main.url(forResource: "poppy_japanese_loop", withExtension: "wav", subdirectory: "Audio") else { return }
            musicPlayer = try? AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1
            musicPlayer?.prepareToPlay()
        }
        musicPlayer?.volume = musicVolume(for: volume)
        if musicPlayer?.isPlaying == false {
            musicPlayer?.play()
        }
        #endif
    }

    func updateMusicVolume(_ volume: VolumeLevel) {
        #if os(iOS)
        musicPlayer?.volume = musicVolume(for: volume)
        if volume == .quiet {
            musicPlayer?.volume = 0.08
        }
        #endif
    }

    func play(_ sound: SpriteSound, volume: VolumeLevel = .moderate) {
        #if os(iOS)
        configureSession()
        let player: AVAudioPlayer?
        if let cached = soundPlayers[sound] {
            player = cached
        } else if let url = Bundle.main.url(forResource: sound.fileName, withExtension: "wav", subdirectory: "Audio"),
                  let created = try? AVAudioPlayer(contentsOf: url) {
            created.prepareToPlay()
            soundPlayers[sound] = created
            player = created
        } else {
            player = nil
        }

        player?.stop()
        player?.currentTime = 0
        player?.volume = effectVolume(for: volume)
        player?.play()
        #endif
    }

    #if os(iOS)
    private func configureSession() {
        try? AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }

    private func musicVolume(for volume: VolumeLevel) -> Float {
        switch volume {
        case .quiet: return 0.08
        case .moderate: return 0.18
        case .loud: return 0.32
        }
    }

    private func effectVolume(for volume: VolumeLevel) -> Float {
        switch volume {
        case .quiet: return 0.18
        case .moderate: return 0.42
        case .loud: return 0.72
        }
    }
    #endif
}
