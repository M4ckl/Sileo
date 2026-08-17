import SwiftUI
import Observation

@Observable
class SettingsViewModel {
    static let shared = SettingsViewModel()

    var selectedSoundID: String {
        didSet { UserDefaults.standard.set(selectedSoundID, forKey: "selectedSoundID") }
    }
    
    var selectedThemeID: String {
        didSet { UserDefaults.standard.set(selectedThemeID, forKey: "selectedThemeID") }
    }

    private init() {
        self.selectedSoundID = UserDefaults.standard.string(forKey: "selectedSoundID") ?? "rain"
        self.selectedThemeID = UserDefaults.standard.string(forKey: "selectedThemeID") ?? "blue"
    }
    
    func getCurrentTheme() -> AppTheme {
        AppTheme.all.first { $0.id == selectedThemeID } ?? AppTheme.all[0]
    }
    
    func getCurrentSound() -> AppSound {
        AppSound.all.first { $0.id == selectedSoundID } ?? AppSound.all[0]
    }
}
