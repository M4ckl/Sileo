import SwiftUI
import AVFoundation
import Observation

@Observable
class PauseEngine {
    
    enum PauseState {
        case idle       // Выбор времени
        case running    // Идет время
        case paused     // Пауза (заморозка)
        case finished   // Галочка
    }
    
    var state: PauseState = .idle
    var selectedMinutes: Int = 0
    var progress: Double = 0.0
    var remainingSeconds: Int = 0
    
    private var timer: Timer?
    private let userManager = UserManager.shared
    
    // --- АУДИО КОМПОНЕНТЫ ---
    private var audioPlayer: AVAudioPlayer?
    private var volumeTimer: Timer? // Таймер для плавного затухания звука
    
    private let haptic = UIImpactFeedbackGenerator(style: .soft)
    private let notification = UINotificationFeedbackGenerator()
    
    private var todayKey: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "daily_total_" + formatter.string(from: Date())
    }
    
    var todayUsageCount: Int {
            HistoryManager.shared.getData(for: HistoryManager.shared.currentDate).sessionsCount
        }
    
    var totalMinutesToday: Int {
            HistoryManager.shared.getData(for: HistoryManager.shared.currentDate).totalMinutes
        }
    
    init() {
        setupAudioSession() // Настройка звука при запуске
    }
    
    // --- УПРАВЛЕНИЕ ---
    
    func startPause() -> Bool {
            // 1. Проверка лимитов для БЕСПЛАТНЫХ пользователей
            if !userManager.isPremium {
                let todaySessions = HistoryManager.shared.getData(for: HistoryManager.shared.currentDate).sessionsCount
                if todaySessions >= userManager.freeDailyLimit {
                    return false // Запрещаем старт, нужно показать Paywall
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
            // Ставим на паузу
            timer?.invalidate()
            
            // Ставим звук на паузу (плавно)
            pauseAmbientSound()
            
            withAnimation(.easeInOut(duration: 0.3)) {
                state = .paused
            }
            haptic.prepare()
            haptic.impactOccurred(intensity: 0.6)
            
        } else if state == .paused {
            // Возобновляем
            // Возобновляем звук
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
        
        // Останавливаем звук (плавно)
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
    
    // --- БЕЗЕЛЬ И ВРЕМЯ ---
    
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
        stopAmbientSound() // На всякий случай глушим звук
        withAnimation {
            state = .idle
            progress = 0
        }
    }
    
    // --- ЛОГИКА АУДИО (AVAudioPlayer) ---
    
    private func setupAudioSession() {
        do {
            // .playback позволяет играть звук даже в беззвучном режиме и при блокировке экрана
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio Session Error: \(error)")
        }
    }
    
    private func playAmbientSound() {
            if let player = audioPlayer, player.isPlaying { return }
           
            // Берем имя файла из менеджера
            let soundFilename = userManager.getCurrentSound().filename
        
            if soundFilename.isEmpty {
                // Если вдруг что-то играло — останавливаем
                if let player = audioPlayer, player.isPlaying {
                    fadeVolume(to: 0.0, duration: 0.5) { [weak self] in
                        self?.audioPlayer?.stop()
                    }
                }
                return // ⛔️ Выходим из функции, дальше не идем
            }
            
            // Создаем плеер заново, если файл изменился или плеера нет
            // (Упрощенно: пересоздаем всегда для надежности смены трека)
            do {
                if let url = Bundle.main.url(forResource: soundFilename, withExtension: "mp3") {
                    audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer?.numberOfLoops = -1
                    audioPlayer?.prepareToPlay()
                } else {
                    print("Sound file \(soundFilename) not found")
                }
            } catch {
                print("Audio Error: \(error)")
            }
           
            audioPlayer?.volume = 0
            audioPlayer?.play()
            fadeVolume(to: 1.0, duration: 2.0)
        }
    
    private func pauseAmbientSound() {
        // Плавно уводим громкость в 0, потом ставим паузу
        fadeVolume(to: 0.0, duration: 0.5) { [weak self] in
            self?.audioPlayer?.pause()
        }
    }
    
    private func stopAmbientSound() {
        // Плавно уводим громкость в 0, потом стоп
        fadeVolume(to: 0.0, duration: 2.0) { [weak self] in
            self?.audioPlayer?.stop()
            self?.audioPlayer = nil // Освобождаем память, чтобы при следующем старте создать заново
        }
    }
    
    // Хелпер для плавного изменения громкости
    private func fadeVolume(to targetVolume: Float, duration: TimeInterval, completion: (() -> Void)? = nil) {
        volumeTimer?.invalidate() // Сбрасываем старый таймер если был
        
        guard let player = audioPlayer else { return }
        
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
            player.volume = max(0.0, min(1.0, newVolume)) // Держим в рамках 0...1
            
            if currentStep >= steps {
                timer.invalidate()
                completion?()
            }
        }
    }
}
