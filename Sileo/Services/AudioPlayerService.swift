import AVFoundation

class AudioPlayerService {
    
    private var audioPlayer: AVAudioPlayer?
    private var fadeOutWorkItem: DispatchWorkItem?
    
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
        fadeOutWorkItem?.cancel()
        
        guard !filename.isEmpty else {
            stop()
            return
        }
        
        guard let url = Bundle.main.url(forResource: filename, withExtension: "m4a") ??
                Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            print("Sound file \(filename) not found")
            return
        }
        
        do {
            if audioPlayer?.url != url {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1
                audioPlayer?.prepareToPlay()
            }
            audioPlayer?.play()
            audioPlayer?.setVolume(1.0, fadeDuration: 2.0)
            
        } catch {
            print("Audio Error: \(error.localizedDescription)")
        }
    }
    
    func pause() {
        guard let player = audioPlayer, player.isPlaying else { return }
        
        fadeOutWorkItem?.cancel()
        
        player.setVolume(0.0, fadeDuration: 0.5)
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.audioPlayer?.pause()
        }
        fadeOutWorkItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
    }
    
    func stop() {
        guard let player = audioPlayer else { return }
        
        fadeOutWorkItem?.cancel()
        
        player.setVolume(0.0, fadeDuration: 2.0)
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.audioPlayer?.stop()
            self?.audioPlayer = nil
        }
        fadeOutWorkItem = workItem
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: workItem)
    }
}
