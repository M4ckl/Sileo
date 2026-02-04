import SwiftUI
import AVFoundation
import Observation

@Observable
class PauseEngine {
    
    enum PauseState {
        case idle
        case running
        case paused
        case finished
    }
    
    var state: PauseState = .idle
    var selectedMinutes: Int = 0
    var progress: Double = 0.0
    var remainingSeconds: Int = 0
    
    private var timer: Timer?
    private let userManager = UserManager.shared
    
    private var audioPlayer: AVAudioPlayer?
    private var volumeTimer: Timer?
    
    private let haptic = UIImpactFeedbackGenerator(style: .soft)
    private let notification = UINotificationFeedbackGenerator()
    
    var todayUsageCount: Int {
        HistoryManager.shared.getData(for: HistoryManager.shared.currentDate).sessionsCount
    }
    
    var totalMinutesToday: Int {
        HistoryManager.shared.getData(for: HistoryManager.shared.currentDate).totalMinutes
    }
    
    init() {
        setupAudioSession()
    }
    
    func startPause() -> Bool {
        if !userManager.isPremium {
            let todaySessions = HistoryManager.shared.getData(for: HistoryManager.shared.currentDate).sessionsCount
            if todaySessions >= userManager.freeDailyLimit {
                return false
            }
        }
        
        if state == .idle {
            remainingSeconds = selectedMinutes * 60
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            state = .running
        }
        
        playAmbientSound()
        startTimer()
        return true
    }
    
    func togglePause() {
        if state == .running {
            timer?.invalidate()
            pauseAmbientSound()
            
            withAnimation(.easeInOut(duration: 0.3)) {
                state = .paused
            }
            haptic.prepare()
            haptic.impactOccurred(intensity: 0.6)
            
        } else if state == .paused {
            playAmbientSound()
            startTimer()
            
            withAnimation(.easeInOut(duration: 0.3)) {
                state = .running
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        guard remainingSeconds > 0 else {
            finishSession()
            return
        }
        
        remainingSeconds -= 1
        
        let totalSeconds = Double(selectedMinutes * 60)
        withAnimation(.linear(duration: 1.0)) {
            progress = 1.0 - (Double(remainingSeconds) / totalSeconds)
        }
    }
    
    private func finishSession() {
        timer?.invalidate()
        stopAmbientSound()
        
        HistoryManager.shared.addSession(minutes: selectedMinutes)
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            state = .finished
        }
        notification.prepare()
        notification.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            if self?.state == .finished {
                self?.reset()
            }
        }
    }
    
    func updateTimeFromBezel(angle: Double) {
        let normalizedAngle = angle < 0 ? angle + 360 : angle
        let p = normalizedAngle / 360.0
        let newMinutes = max(1, Int(p * 60))
        
        if newMinutes != selectedMinutes {
            haptic.prepare()
            haptic.impactOccurred(intensity: 0.3)
            selectedMinutes = newMinutes
        }
    }
    
    func reset() {
        stopAmbientSound()
        withAnimation {
            state = .idle
            progress = 0
        }
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Session Error: \(error)")
        }
    }
    
    private func playAmbientSound() {
        if let player = audioPlayer, player.isPlaying { return }
        
        let soundFilename = userManager.getCurrentSound().filename
        
        if soundFilename.isEmpty {
            if let player = audioPlayer, player.isPlaying {
                fadeVolume(to: 0.0, duration: 0.5) { [weak self] in
                    self?.audioPlayer?.stop()
                }
            }
            return
        }
        
        do {
            var url = Bundle.main.url(forResource: soundFilename, withExtension: "m4a")
            if url == nil {
                url = Bundle.main.url(forResource: soundFilename, withExtension: "mp3")
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
                    fadeVolume(to: 1.0, duration: 2.0)
                }
            } else {
                print("Sound file \(soundFilename) not found")
            }
        } catch {
            print("Audio Error: \(error)")
        }
    }
    
    private func pauseAmbientSound() {
        fadeVolume(to: 0.0, duration: 0.5) { [weak self] in
            self?.audioPlayer?.pause()
        }
    }
    
    private func stopAmbientSound() {
        fadeVolume(to: 0.0, duration: 2.0) { [weak self] in
            self?.audioPlayer?.stop()
            self?.audioPlayer = nil
        }
    }
    
    private func fadeVolume(to targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        volumeTimer?.invalidate()
        
        guard let player = audioPlayer else { return }
        
        if abs(player.volume - targetVolume) < 0.01 {
            completion?()
            return
        }
        
        let steps = 20
        let stepDuration = duration / Double(steps)
        let startVolume = player.volume
        let volumeChange = targetVolume - startVolume
        
        var currentStep = 0
        
        volumeTimer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { [weak self] timer in
            guard let self = self, let player = self.audioPlayer else {
                timer.invalidate()
                return
            }
            
            currentStep += 1
            let newVolume = startVolume + (volumeChange * Float(currentStep) / Float(steps))
            player.volume = max(0.0, min(1.0, newVolume))
            
            if currentStep >= steps {
                timer.invalidate()
                completion?()
            }
        }
    }
}
