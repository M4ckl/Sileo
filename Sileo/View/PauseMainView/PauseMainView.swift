import SwiftUI

struct PauseMainView: View {
    @State private var engine = PauseEngine()
    
    @State private var showCalendar = false
    @State private var showProfile = false
    @State private var isTouchingBezel = false
    @State private var showLimitWarning = false
    // Animation States
    @State private var isBreathing = false
    @State private var isFocusMode = false
    @State private var timeAdjustment: TimeInterval = 0
    @State private var pauseStartTime: Date?
    
    @Environment(UserManager.self) var userManager
    @Environment(\.colorScheme) var colorScheme
        
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        return formatter.string(from: Date())
    }
    
    var isLimitReached: Bool {
            // Если не премиум И использовал 6 или больше попыток
            return !userManager.isPremium && engine.todayUsageCount >= userManager.freeDailyLimit
        }
    
    // Dimensions
    let bezelDiameter: CGFloat = 300
    let circleDiameter: CGFloat = 240
    
    var body: some View {
        NavigationStack {
            ZStack {
                // --- 1. BACKGROUND ---
                BackgroundView()
                    .scaleEffect(isBreathing ? 1.1 : 1.0)
                    .animation(isBreathing ? .easeInOut(duration: 6).repeatForever(autoreverses: true) : .easeOut(duration: 1.5), value: isBreathing)
                
                // --- 2. MAIN CONTENT ---
                VStack {
                    Spacer()
                    
                    // --- CENTER (Bezel + Circle) ---
                    ZStack {
                        BezelView(
                            minutes: $engine.selectedMinutes,
                            size: bezelDiameter,
                            theme: theme,
                            onDragStart: { withAnimation(.interactiveSpring()) { isTouchingBezel = true } },
                            onDragEnd: { withAnimation(.spring()) { isTouchingBezel = false } }
                        )
                        .frame(width: bezelDiameter + 40, height: bezelDiameter + 40)
                        .opacity(engine.state == .idle ? 1.0 : 0.0)
                        .allowsHitTesting(engine.state == .idle)
                        .scaleEffect(engine.state == .idle ? 1.0 : 0.9)
                        .allowsHitTesting(engine.state == .idle)
                        
                        mainCircle
                            .frame(width: circleDiameter, height: circleDiameter)
                            .scaleEffect(isTouchingBezel || isFocusMode ? 1.05 : 1.0)
                            .offset(y: isFocusMode ? -20 : 0)
                    }
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isFocusMode)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isTouchingBezel)
                    .animation(.easeInOut(duration: 0.4), value: engine.state)
                    .animation(.easeInOut(duration: 0.5), value: userManager.selectedThemeID)
                    
                    Spacer()
                    
                    if showLimitWarning {
                                            limitWarningView
                                                .padding(.bottom, 10)
                                                .transition(.move(edge: .bottom).combined(with: .opacity))
                                                .zIndex(10) // Ensure it appears on top
                                        }
                    
                    // --- 3. BOTTOM WIDGET PANEL ---
                    bottomWidgets
                        .padding(.bottom, 20)
                }
                .safeAreaPadding(.bottom)
            }
            // ❌ УБРАЛИ: .navigationDestination(...)
        }
        // ✅ ДОБАВИЛИ: Полный экран (Sheet)
        .fullScreenCover(isPresented: $showCalendar) {
            // Обязательно новый NavigationStack, чтобы внутри HistoryView работал Toolbar
            NavigationStack {
                HistoryView()
            }
        }
        .fullScreenCover(isPresented: $showProfile) {
            // Обязательно новый NavigationStack, чтобы внутри HistoryView работал Toolbar
            NavigationStack {
                ProfileView()
            }
        }
        
        // --- 4. ANIMATION ORCHESTRATOR ---
        .onChange(of: engine.state) { _, newState in
            if newState == .running {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) { isFocusMode = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation { isBreathing = true }
                }
                if let start = pauseStartTime {
                    timeAdjustment += Date().timeIntervalSince(start)
                    pauseStartTime = nil
                }
            } else if newState == .paused {
                pauseStartTime = Date()
            } else if newState == .finished {
                withAnimation { isBreathing = false }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { isFocusMode = false }
                timeAdjustment = 0
                pauseStartTime = nil
            } else if newState == .idle {
                withAnimation { isBreathing = false }
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { isFocusMode = false }
                timeAdjustment = 0
                pauseStartTime = nil
            }
        }
        
        .task {
                    // При запуске главного экрана проверяем подписку
                    await StoreManager.shared.checkSubscriptionStatus()
                }
    }
    
    var limitWarningView: some View {
            Text("Daily limit of 6 pauses reached")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.95) : theme.textColor)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .glassEffect(.clear.tint(colorScheme == .dark ? .black.opacity(0.5) : .white.opacity(0.2)))
        }
    
    var mainCircle: some View {
        ZStack {
            Circle()
                .fill(Color(theme.backColor1).opacity(0.4))
                .glassEffect(.clear.interactive())
                .shadow(color: Color.black.opacity(0.05), radius: 20, x: 5, y: 5)
            
            if engine.state == .idle {
                timeInfoView(color: theme.accentColor.opacity(0.8))
                    .transition(.opacity)
            } else {
                TimelineView(.animation(paused: engine.state == .paused)) { timeline in
                    let waveTime = timeline.date.timeIntervalSinceReferenceDate - timeAdjustment
                    let wave = Wave(
                        offset: Angle(degrees: waveTime * 60),
                        percent: engine.progress
                    )
                    ZStack {
                        timeInfoView(color: theme.accentColor.opacity(0.8))
                        wave
                            .fill(theme.accentColor.opacity(0.6))
                            .clipShape(Circle())
                        timeInfoView(color: .white)
                            .frame(width: circleDiameter, height: circleDiameter)
                            .mask(wave.clipShape(Circle()))
                    }
                }
                .opacity(engine.state == .paused ? 0.8 : 1.0)
                .transition(.opacity)
            }
            
            if engine.state == .finished {
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(10)
            }
        }
        .onTapGesture { handleCircleTap() }
    }
    
    @ViewBuilder
        func timeInfoView(color: Color) -> some View {
            VStack(spacing: 0) {
                if engine.state != .finished {
                    // ✅ RESTORED STANDARD TIME: User sees what they select (e.g., 10:00) even if limited
                    Text(engine.state == .idle ? String(format: "%02d:00", engine.selectedMinutes) : timeString(time: engine.remainingSeconds))
                        .font(.system(size: 54, weight: .light, design: .rounded))
                        .foregroundColor(color)
                        .contentTransition(.numericText())
                        .offset(y: shouldShowStartButton ? -15 : 0)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: shouldShowStartButton)
                    
                    if shouldShowStartButton {
                        Text("START")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .tracking(2)
                            .foregroundColor(color)
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                            .padding(.top, 4)
                    }
                    
                    if engine.state == .paused {
                        Text("PAUSED")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .tracking(2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.black.opacity(0.2))
                            .clipShape(Capsule())
                            .padding(.top, 5)
                    }
                }
            }
        }
    
    var bottomWidgets: some View {
        ZStack {
            if engine.state == .running || engine.state == .paused {
                HStack(spacing: 8) {
                    AudioVisualizerView(theme: theme)
                    Text("DO NOTHING")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 36)
                        .tracking(2)
                        .foregroundColor(theme.textColor)
                        .glassEffect(.clear.interactive())
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                HStack(spacing: 8) {
                    // ✅ КНОПКА КАЛЕНДАРЯ
                    Button(action: { showCalendar = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 24))
                        }
                        .padding(.vertical ,11)
                        .padding(.horizontal , 9)
                        .clipShape(Capsule())
                        .glassEffect(.clear.interactive())
                        .foregroundStyle(isFocusMode ? .clear : theme.textColor)
                    }
                    .opacity(isFocusMode ? 0 : 1)
                    .allowsHitTesting(!isFocusMode)
                    
                    // ТЕКСТ СТАТИСТИКИ
                    HStack(spacing: 0) {
                        Text("Total pauses for today: ")
                            .foregroundColor(theme.textColor.opacity(0.5))
                        Text("\(engine.totalMinutesToday) min")
                            .foregroundColor(theme.textColor)
                            .fontWeight(.bold)
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .padding(.vertical, 14)
                    .padding(.horizontal, 16)
                    .cornerRadius(20)
                    .glassEffect(.clear.interactive())
                    
                    // КНОПКА ПРОФИЛЯ
                    Button(action: { showProfile = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 24))
                        }
                        .padding(10)
                        .clipShape(Capsule())
                        .glassEffect(.clear.interactive())
                        .foregroundStyle(isFocusMode ? .clear : theme.textColor)
                    }
                    .opacity(isFocusMode ? 0 : 1)
                    .allowsHitTesting(!isFocusMode)
                }
                .transition(.opacity)
            }
        }
    }
    
    // --- LOGIC ---
    var shouldShowStartButton: Bool {
        return engine.state == .idle && engine.selectedMinutes > 0 && !isTouchingBezel
    }
    
        
        func handleCircleTap() {
            if engine.state == .idle {
                if engine.selectedMinutes > 0 {
                    
                    // ✅ CHECK LIMIT ON TAP
                    if isLimitReached {
                        // 1. Error Haptic
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                        
                        // 2. Show Warning
                        withAnimation(.spring()) {
                            showLimitWarning = true
                        }
                        
                        // 3. Auto-hide after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation {
                                showLimitWarning = false
                            }
                        }
                        
                        // 4. STOP HERE (Don't start engine)
                        return
                    }
                    
                    // Start Normal
                    if !engine.startPause() {
                        UINotificationFeedbackGenerator().notificationOccurred(.error)
                    }
                    
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
            } else if engine.state == .running {
                engine.togglePause()
            } else if engine.state == .paused {
                engine.togglePause()
            } else if engine.state == .finished {
                engine.reset()
            }
        }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
}
