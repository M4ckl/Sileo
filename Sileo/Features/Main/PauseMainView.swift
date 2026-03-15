import SwiftUI

struct PauseMainView: View {
    @State private var engine = PauseEngine()
    
    @Environment(UserManager.self) var userManager
    @Environment(\.colorScheme) var colorScheme
    
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    var body: some View {
        ZStack {
            StandardInterfaceView(engine: engine)
        }
        .onChange(of: engine.state) { _, _ in updateIdleTimer() }
        .task { await StoreManager.shared.checkSubscriptionStatus() }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    func updateIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = (engine.state == .running)
    }
}
