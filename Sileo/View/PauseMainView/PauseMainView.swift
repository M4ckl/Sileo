import SwiftUI

struct PauseMainView: View {
    @State private var engine = PauseEngine()
    
    @Environment(UserManager.self) var userManager
    @Environment(\.colorScheme) var colorScheme
    
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    var body: some View {
        ZStack {
            StandardInterfaceView(engine: engine)
        }
        .onChange(of: engine.state) { _, _ in updateIdleTimer() }
        .task { await StoreManager.shared.checkSubscriptionStatus() }
    }
    
    func updateIdleTimer() {
        if engine.state == .running {
            UIApplication.shared.isIdleTimerDisabled = true
        } else {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}

struct TimerContainerView: View {
    @Bindable var engine: PauseEngine
    let theme: AppTheme
    
    @State private var isTouchingBezel = false
    @State private var isFocusMode = false
    @State private var showLimitWarning = false
    
    @Environment(UserManager.self) var userManager
    @Environment(\.colorScheme) var colorScheme
    
    let bezelDiameter: CGFloat = 300
    let circleDiameter: CGFloat = 240
    
    var isLimitReached: Bool {
        return !userManager.isPremium && engine.todayUsageCount >= userManager.freeDailyLimit
    }
    
    var body: some View {
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
            
            mainCircle
                .frame(width: circleDiameter, height: circleDiameter)
                .scaleEffect(isTouchingBezel || isFocusMode ? 1.05 : 1.0)
                .offset(y: isFocusMode ? -20 : 0)
            
            if showLimitWarning {
                VStack {
                    Spacer()
                    Text("Daily limit reached")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 8).padding(.horizontal, 16)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(20)
                }
                .padding(.bottom, -60)
                .transition(.opacity)
                .zIndex(10)
            }
        }
        .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isFocusMode)
        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isTouchingBezel)
        .animation(.easeInOut(duration: 0.4), value: engine.state)
        .onChange(of: engine.state) { _, newState in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isFocusMode = (newState == .running)
            }
        }
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
                    let waveTime = timeline.date.timeIntervalSinceReferenceDate
                    let wave = Wave(offset: Angle(degrees: waveTime * 60), percent: engine.progress)
                    ZStack {
                        timeInfoView(color: theme.accentColor.opacity(0.8))
                        wave.fill(theme.accentColor.opacity(0.6)).clipShape(Circle())
                        timeInfoView(color: .white).frame(width: circleDiameter, height: circleDiameter).mask(wave.clipShape(Circle()))
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
                        .padding(.horizontal, 10).padding(.vertical, 4)
                        .background(Color.black.opacity(0.2)).clipShape(Capsule())
                        .padding(.top, 5)
                }
            }
        }
    }
    
    var shouldShowStartButton: Bool {
        return engine.state == .idle && engine.selectedMinutes > 0 && !isTouchingBezel
    }
    
    func handleCircleTap() {
        if engine.state == .idle {
            if engine.selectedMinutes > 0 {
                if isLimitReached {
                    withAnimation(.spring()) { showLimitWarning = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { withAnimation { showLimitWarning = false } }
                    return
                }
                if !engine.startPause() { UINotificationFeedbackGenerator().notificationOccurred(.error) }
            } else { UINotificationFeedbackGenerator().notificationOccurred(.error) }
        } else if engine.state == .running { engine.togglePause() }
        else if engine.state == .paused { engine.togglePause() }
        else if engine.state == .finished { engine.reset() }
    }
    
    func timeString(time: Int) -> String {
        let minutes = time / 60
        let seconds = time % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct StandardInterfaceView: View {
    @Bindable var engine: PauseEngine
    
    @State private var showCalendar = false
    @State private var showProfile = false
    @State private var isBreathing = false
    
    // Animation specific
    @State private var timeAdjustment: TimeInterval = 0
    @State private var pauseStartTime: Date?
    
    @Environment(UserManager.self) var userManager
    @Environment(\.colorScheme) var colorScheme
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                    .scaleEffect(isBreathing ? 1.1 : 1.0)
                    .animation(isBreathing ? .easeInOut(duration: 6).repeatForever(autoreverses: true) : .easeOut(duration: 1.5), value: isBreathing)
                    .ignoresSafeArea()
                
                VStack {
                    Spacer()
                    
                    ZStack {
                        TimerContainerView(engine: engine, theme: theme)
                    }
                    
                    Spacer()
                    
                    bottomWidgets
                        .padding(.bottom, 20)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
                .safeAreaPadding(.bottom)
            }
            .fullScreenCover(isPresented: $showCalendar) { NavigationStack { HistoryView() } }
            .fullScreenCover(isPresented: $showProfile) { NavigationStack { ProfileView() } }
            .onChange(of: engine.state) { _, newState in
                if newState == .running {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { withAnimation { isBreathing = true } }
                } else if newState == .idle || newState == .finished {
                    withAnimation { isBreathing = false }
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
                        .padding(.vertical, 12).padding(.horizontal, 36)
                        .tracking(2).foregroundColor(theme.textColor)
                        .glassEffect(.clear)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                HStack(spacing: 8) {
                    Button(action: { showCalendar = true }) {
                        HStack(spacing: 6) { Image(systemName: "calendar").font(.system(size: 24)) }
                            .padding(.vertical ,11).padding(.horizontal , 9)
                            .clipShape(Capsule()).glassEffect(.clear.interactive())
                            .foregroundStyle(engine.state == .running ? .clear : theme.textColor)
                    }.opacity(engine.state == .running ? 0 : 1).allowsHitTesting(engine.state != .running)
                    
                    HStack(spacing: 0) {
                        Text("Total pauses for today: ").foregroundColor(theme.textColor.opacity(0.5))
                        Text("\(engine.totalMinutesToday) min").foregroundColor(theme.textColor).fontWeight(.bold)
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .padding(.vertical, 14).padding(.horizontal, 16)
                    .cornerRadius(20).glassEffect(.clear)
                    
                    Button(action: { showProfile = true }) {
                        HStack(spacing: 6) { Image(systemName: "person.circle").font(.system(size: 24)) }
                            .padding(10).clipShape(Capsule()).glassEffect(.clear.interactive())
                            .foregroundStyle(engine.state == .running ? .clear : theme.textColor)
                    }.opacity(engine.state == .running ? 0 : 1).allowsHitTesting(engine.state != .running)
                }
                .transition(.opacity)
            }
        }
    }
}
