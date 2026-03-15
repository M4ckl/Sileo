import SwiftUI

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
                    Task {
                        try? await Task.sleep(nanoseconds: 3_000_000_000)
                        await MainActor.run {
                            withAnimation { showLimitWarning = false }
                        }
                    }
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
