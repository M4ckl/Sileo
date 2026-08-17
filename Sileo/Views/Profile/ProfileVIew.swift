import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(SettingsViewModel.self) var settingManager
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var theme: AppTheme { settingManager.getCurrentTheme() }

    @State private var navigateToAchievements = false
    @State private var showSounds = false
    @State private var showThemes = false

    var body: some View {
        ProfileContentView(
            isDarkMode: $isDarkMode,
            navigateToAchievements: $navigateToAchievements,
            showSounds: $showSounds,
            showThemes: $showThemes,
            theme: theme,
            dismissAction: { dismiss() }
        )
        .environment(\.colorScheme, isDarkMode ? .dark : .light)
        .animation(.easeInOut(duration: 0.5), value: isDarkMode)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToAchievements) { AchievementsGridView(isDarkMode: isDarkMode) }
        .sheet(isPresented: $showSounds) { SelectionSheet(type: .sound, theme: theme).presentationDetents([.fraction(0.7)]).presentationDragIndicator(.visible) }
        .sheet(isPresented: $showThemes) { SelectionSheet(type: .theme, theme: theme).presentationDetents([.fraction(0.7)]).presentationDragIndicator(.visible) }
    }
}
