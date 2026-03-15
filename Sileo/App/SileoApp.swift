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
    @State private var isAppReady = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isAppReady {
                    PauseMainView()
                        .transition(.opacity)
                } else {
                    SplashView(
                        theme: userManager.getCurrentTheme(),
                        isAppReady: $isAppReady
                    )
                    .zIndex(1)
                    .transition(.opacity)
                }
            }
            .environment(userManager)
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .animation(.easeInOut(duration: 0.5), value: isDarkMode)
            .animation(.easeInOut(duration: 0.8), value: isAppReady)
            .task {
                await StoreManager.shared.checkSubscriptionStatus()
                await StoreManager.shared.loadProducts()
            }
        }
    }
}
