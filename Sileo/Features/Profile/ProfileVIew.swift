import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(UserManager.self) var userManager
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    var theme: AppTheme { userManager.getCurrentTheme() }

    @State private var navigateToAchievements = false
    @State private var navigateToPaywall = false
    @State private var navigateToManageSubscription = false
    @State private var showSounds = false
    @State private var showThemes = false
    
    var body: some View {
        ZStack {
            // WHITE THEME
            ProfileContentView(
                isDarkMode: $isDarkMode,
                navigateToAchievements: $navigateToAchievements,
                navigateToPaywall: $navigateToPaywall,
                navigateToManageSubscription: $navigateToManageSubscription,
                showSounds: $showSounds,
                showThemes: $showThemes,
                theme: theme,
                dismissAction: { dismiss() }
            )
            .environment(\.colorScheme, .light)
            .opacity(isDarkMode ? 0 : 1)
            .allowsHitTesting(!isDarkMode)
            
            // DARK THEME
            ProfileContentView(
                isDarkMode: $isDarkMode,
                navigateToAchievements: $navigateToAchievements,
                navigateToPaywall: $navigateToPaywall,
                navigateToManageSubscription: $navigateToManageSubscription,
                showSounds: $showSounds,
                showThemes: $showThemes,
                theme: theme,
                dismissAction: { dismiss() }
            )
            .environment(\.colorScheme, .dark)
            .opacity(isDarkMode ? 1 : 0)
            .allowsHitTesting(isDarkMode)
        }
        .animation(.easeInOut(duration: 0.5), value: isDarkMode)
        .navigationBarHidden(true)
        .navigationDestination(isPresented: $navigateToAchievements) { AchievementsGridView(isDarkMode: isDarkMode) }
        .navigationDestination(isPresented: $navigateToPaywall) { PaywallView() }
        .navigationDestination(isPresented: $navigateToManageSubscription) { ManageSubscriptionView() }
        .sheet(isPresented: $showSounds) { SelectionSheet(type: .sound, theme: theme).presentationDetents([.fraction(0.7)]).presentationDragIndicator(.visible) }
        .sheet(isPresented: $showThemes) { SelectionSheet(type: .theme, theme: theme).presentationDetents([.fraction(0.7)]).presentationDragIndicator(.visible) }
    }
}
