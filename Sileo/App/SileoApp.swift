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
    
    var body: some Scene {
        WindowGroup {
            PauseMainView()
                .environment(userManager)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .animation(.easeInOut(duration: 0.5), value: isDarkMode)
                .task {
                    await StoreManager.shared.checkSubscriptionStatus()
                    await StoreManager.shared.loadProducts()
                }
        }
    }
}
