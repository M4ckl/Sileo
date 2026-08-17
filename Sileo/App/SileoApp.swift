import SwiftUI
import SwiftData

@main
struct SileoApp: App {

    @State private var settingManager = SettingsViewModel.shared
    @State private var historyManager = HistoryViewModel.shared
    @State private var gamingManager = GamificationViewModel.shared
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasSeenOnboarding {
                    PauseMainView()
                        .transition(.opacity)
                } else {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                        .transition(.opacity)
                }
            }
            .environment(settingManager)
            .environment(historyManager)
            .environment(gamingManager)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .animation(.easeInOut(duration: 0.5), value: isDarkMode)
            .animation(.easeInOut(duration: 0.8), value: hasSeenOnboarding)
        }
    }
}
