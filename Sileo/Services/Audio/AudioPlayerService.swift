import AVFoundation

class AudioPlayerService {
    private var audioPlayer: AVAudioPlayer?
    
    init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Session Error: \(error)")
        }
    }
    
    func play(filename: String) {
        if let player = audioPlayer, player.isPlaying { return }
        
        if filename.isEmpty {
            stop()
            return
        }
        
        do {
            var url = Bundle.main.url(forResource: filename, withExtension: "m4a")
            if url == nil {
                url = Bundle.main.url(forResource: filename, withExtension: "mp3")
            }
            
            if let soundUrl = url {
                if audioPlayer == nil || audioPlayer?.url != soundUrl {
                    audioPlayer = try AVAudioPlayer(contentsOf: soundUrl)
                    audioPlayer?.numberOfLoops = -1
                    audioPlayer?.prepareToPlay()
                }
                
                if audioPlayer?.isPlaying == false {
                    audioPlayer?.volume = 0
                    audioPlayer?.play()
                    audioPlayer?.setVolume(1.0, fadeDuration: 2.0)
                }
            } else {
                print("Sound file \(filename) not found")
            }
        } catch {
            print("Audio Error: \(error)")
        }
    }
    
    func pause() {
        guard let player = audioPlayer, player.isPlaying else { return }
        
        player.setVolume(0.0, fadeDuration: 0.5)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.audioPlayer?.pause()
        }
    }
    
    func stop() {
        guard let player = audioPlayer else { return }
        
        player.setVolume(0.0, fadeDuration: 2.0)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.audioPlayer?.stop()
            self?.audioPlayer = nil
        }
    }
}
