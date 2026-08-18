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
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
        }
    }
}
