import SwiftUI

struct StandardInterfaceView: View {
    @Bindable var engine: PauseViewModel
    
    @State private var showCalendar = false
    @State private var showProfile = false
    @State private var isBreathing = false
    
    @Environment(SettingsViewModel.self) var settingManager
    @Environment(\.colorScheme) var colorScheme
    var theme: AppTheme { settingManager.getCurrentTheme() }
    
    var body: some View {
        ZStack {
            BackgroundView(theme: settingManager.getCurrentTheme())
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
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    await MainActor.run {
                        withAnimation { isBreathing = true }
                    }
                }
            } else if newState == .idle || newState == .finished {
                withAnimation { isBreathing = false }
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
