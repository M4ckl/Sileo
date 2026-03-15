import SwiftUI
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

    private var targetEndDate: Date?
    
    private let userManager = UserManager.shared
    private let audioService = AudioPlayerService()
    
    private let haptic = UIImpactFeedbackGenerator(style: .soft)
    private let notification = UINotificationFeedbackGenerator()
    
    var todayUsageCount: Int {
        HistoryManager.shared.getData(for: HistoryManager.shared.currentDate).sessionsCount
    }
    
    var totalMinutesToday: Int {
        HistoryManager.shared.getData(for: HistoryManager.shared.currentDate).totalMinutes
    }
    
    func startPause() -> Bool {
        if !userManager.isPremium {
            if todayUsageCount >= userManager.freeDailyLimit {
                return false
            }
        }
        
        if state == .idle {
            remainingSeconds = selectedMinutes * 60
        }

        targetEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            state = .running
        }
        
        audioService.play(filename: userManager.getCurrentSound().filename)
        startTimer()
        return true
    }
    
    func togglePause() {
        if state == .running {
            timer?.invalidate()
            audioService.pause()

            targetEndDate = nil
            
            withAnimation(.easeInOut(duration: 0.3)) { state = .paused }
            
            haptic.prepare()
            haptic.impactOccurred(intensity: 0.6)
            
        } else if state == .paused {
            targetEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
            
            audioService.play(filename: userManager.getCurrentSound().filename)
            startTimer()
            
            withAnimation(.easeInOut(duration: 0.3)) { state = .running }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    private func tick() {
        guard let endDate = targetEndDate else { return }

        let timeToFinish = endDate.timeIntervalSinceNow
        
        if timeToFinish <= 0 {
            remainingSeconds = 0
            progress = 1.0
            finishSession()
        } else {
            remainingSeconds = Int(ceil(timeToFinish))
            
            let totalSeconds = Double(selectedMinutes * 60)
            withAnimation(.linear(duration: 0.1)) {
                progress = 1.0 - (timeToFinish / totalSeconds)
            }
        }
    }
    
    private func finishSession() {
        timer?.invalidate()
        targetEndDate = nil
        audioService.stop()
        
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
        audioService.stop()
        timer?.invalidate()
        targetEndDate = nil
        
        withAnimation {
            state = .idle
            progress = 0
            remainingSeconds = 0
        }
    }
}
