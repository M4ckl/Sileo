import SwiftUI

struct TimerContainerView: View {
    @Bindable var engine: PauseViewModel
    let theme: AppTheme
    
    @State private var isTouchingBezel = false
    @State private var isFocusMode = false

    @Environment(\.colorScheme) var colorScheme

    let bezelDiameter: CGFloat = 300
    let circleDiameter: CGFloat = 240

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
                TimeInfoView(engine: engine, color: theme.accentColor.opacity(0.8), shouldShowStartButton: shouldShowStartButton)
                    .transition(.opacity)
            } else {
                TimelineView(.animation(paused: engine.state == .paused)) { timeline in
                    let waveTime = timeline.date.timeIntervalSinceReferenceDate
                    let wave = Wave(offset: Angle(degrees: waveTime * 60), percent: engine.progress)
                    ZStack {
                        TimeInfoView(engine: engine, color: theme.accentColor.opacity(0.8), shouldShowStartButton: shouldShowStartButton)
                        wave.fill(theme.accentColor.opacity(0.6)).clipShape(Circle())
                        TimeInfoView(engine: engine, color: .white, shouldShowStartButton: shouldShowStartButton)
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
    
    var shouldShowStartButton: Bool {
        return engine.state == .idle && engine.selectedMinutes > 0 && !isTouchingBezel
    }
    
    func handleCircleTap() {
        if engine.state == .idle {
            if engine.selectedMinutes > 0 {
                engine.startPause()
            } else { UINotificationFeedbackGenerator().notificationOccurred(.error) }
        } else if engine.state == .running { engine.togglePause() }
        else if engine.state == .paused { engine.togglePause() }
        else if engine.state == .finished { engine.reset() }
    }
}
