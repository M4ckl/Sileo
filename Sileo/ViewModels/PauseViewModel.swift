import Foundation
import UIKit
import Observation

@Observable
class PauseViewModel {
    
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
    
    var todayUsageCount: Int {
        HistoryViewModel.shared.getData(for: HistoryViewModel.shared.currentDate).sessionsCount
    }
    
    var totalMinutesToday: Int {
        HistoryViewModel.shared.getData(for: HistoryViewModel.shared.currentDate).totalMinutes
    }
    
    private var timer: Timer?
    private var targetEndDate: Date?
    private var isTransitioning = false
    
    private let settingManager = SettingsViewModel.shared
    private let audioService = AudioPlayerService()
    
    private let haptic = UIImpactFeedbackGenerator(style: .soft)
    private let notification = UINotificationFeedbackGenerator()
    
    @discardableResult
    func startPause() -> Bool {
        if state == .idle {
            remainingSeconds = selectedMinutes * 60
        }

        targetEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
        state = .running
        
        audioService.play(filename: settingManager.getCurrentSound().filename)
        startTimer()
        
        return true
    }
    
    func togglePause() {
        guard !isTransitioning else { return }
        isTransitioning = true
        
        if state == .running {
            timer?.invalidate()
            audioService.pause()
            targetEndDate = nil
            
            state = .paused
            
            haptic.prepare()
            haptic.impactOccurred(intensity: 0.6)
            
        } else if state == .paused {
            targetEndDate = Date().addingTimeInterval(TimeInterval(remainingSeconds))
            audioService.play(filename: settingManager.getCurrentSound().filename)
            startTimer()
            
            state = .running
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.isTransitioning = false
        }
    }
    
    func updateTimeFromBezel(angle: Double) {
        let normalizedAngle = angle < 0 ? angle + 360 : angle
        let progress = normalizedAngle / 360.0
        let newMinutes = max(1, Int(progress * 60))
        
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
        
        state = .idle
        progress = 0
        remainingSeconds = 0
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
            progress = 1.0 - (timeToFinish / totalSeconds)
        }
    }
    
    private func finishSession() {
        timer?.invalidate()
        targetEndDate = nil
        audioService.stop()
        
        HistoryViewModel.shared.addSession(minutes: selectedMinutes)
        
        state = .finished
        
        notification.prepare()
        notification.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            if self?.state == .finished {
                self?.reset()
            }
        }
    }
}
