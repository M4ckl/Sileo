import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

@main
struct SileoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var userManager = UserManager.shared
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
            .environment(userManager)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .animation(.easeInOut(duration: 0.5), value: isDarkMode)
            .animation(.easeInOut(duration: 0.8), value: hasSeenOnboarding) // Плавное исчезновение онбординга
            .task {
                await StoreManager.shared.checkSubscriptionStatus()
                await StoreManager.shared.loadProducts()
            }
        }
    }
}
