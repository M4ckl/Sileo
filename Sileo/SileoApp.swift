import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .portrait
    }
}

@main
struct SileoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    // Менеджер данных
    @State private var userManager = UserManager.shared
    
    // Читаем настройку здесь, в корне
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // Состояние загрузки (теперь SplashView будет менять это значение сам)
    @State private var isAppReady = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                // Логика переключения
                if isAppReady {
                    PauseMainView()
                        .transition(.opacity)
                } else {
                    // ✅ ИЗМЕНЕНИЕ: Передаем Binding ($isAppReady)
                    SplashView(
                        theme: userManager.getCurrentTheme(),
                        isAppReady: $isAppReady
                    )
                    .zIndex(1) // Держим Splash поверх всего во время исчезновения
                    .transition(.opacity)
                }
            }
            // ✅ ВАЖНО: environment передаем всему ZStack
            .environment(userManager)
            
            // Настройки внешнего вида
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .animation(.easeInOut(duration: 0.5), value: isDarkMode)
            // Плавный переход при смене isAppReady
            .animation(.easeInOut(duration: 0.8), value: isAppReady)
            
            // ❌ УДАЛЕНО: .onAppear с таймером.
            // Теперь таймер находится внутри SplashView.
        }
    }
}
