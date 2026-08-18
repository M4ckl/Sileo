import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @Environment(SettingsViewModel.self) var settingManager
    @Environment(\.colorScheme) var colorScheme
    
    var theme: AppTheme { settingManager.getCurrentTheme() }

    @State private var showButton = false
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView(theme: settingManager.getCurrentTheme())
                .ignoresSafeArea()
            
            ParticleMorphView(particleColor: colorScheme == .dark ? .white : theme.accentColor)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            VStack {
                Spacer()

                if showButton {
                    Button(action: {
                        hasSeenOnboarding = true
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }) {
                        Text("Get Started")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(theme.textColor)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .cornerRadius(30)
                            .glassEffect(.clear.interactive().tint(theme.accentColor.opacity(0.1)))
                            .shadow(color: theme.accentColor.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 0)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear {
            Task {
                try? await Task.sleep(nanoseconds: 7_500_000_000)
                
                await MainActor.run {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.8)) {
                        showButton = true
                    }
                }
            }
        }
    }
}
