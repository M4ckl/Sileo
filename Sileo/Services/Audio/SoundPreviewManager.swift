import SwiftUI
import AVFoundation
import Observation

@Observable
class SoundPreviewManager {
    var playingSoundID: String? = nil
    var progress: CGFloat = 0.0
    
    private var player: AVAudioPlayer?
    private var uiTimer: Timer?
    private let previewDuration: TimeInterval = 10.0
    
    init() {
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    func togglePreview(for sound: AppSound) {
        if playingSoundID == sound.id {
            stop(fadeOut: true)
            return
        }
        
        stop(fadeOut: false)
        
        playingSoundID = sound.id
        progress = 0.0
        
        if !sound.filename.isEmpty {
            var url = Bundle.main.url(forResource: sound.filename, withExtension: "m4a")
            if url == nil {
                url = Bundle.main.url(forResource: sound.filename, withExtension: "mp3")
            }
            
            if let soundUrl = url {
                do {
                    player = try AVAudioPlayer(contentsOf: soundUrl)
                    player?.volume = 1.0
                    player?.numberOfLoops = -1
                    player?.prepareToPlay()
                    player?.play()
                } catch {
                    print("Preview Error: \(error)")
                }
            }
        }

        uiTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.progress += 0.05 / self.previewDuration
            
            if self.progress >= 1.0 {
                self.stop(fadeOut: true)
            }
        }
    }
    
    func stop(fadeOut: Bool) {
        uiTimer?.invalidate()
        uiTimer = nil
        
        if let currentPlayer = player, currentPlayer.isPlaying {
            if fadeOut {
                currentPlayer.setVolume(0, fadeDuration: 0.5)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    currentPlayer.stop()
                }
            } else {
                currentPlayer.stop()
            }
        }
        
        player = nil
        playingSoundID = nil
        progress = 0.0
    }
}
