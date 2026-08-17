import SwiftUI

struct PauseMainView: View {
    @State private var engine = PauseViewModel()
    
    @Environment(SettingsViewModel.self) var settingManager
    @Environment(\.colorScheme) var colorScheme
    
    var theme: AppTheme { settingManager.getCurrentTheme() }
    
    var body: some View {
        ZStack {
            StandardInterfaceView(engine: engine)
        }
        .onChange(of: engine.state) { _, _ in updateIdleTimer() }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
    
    func updateIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = (engine.state == .running)
    }
}
