import SwiftUI
import Observation

struct AppSound: Identifiable, Equatable {
    let id: String
    let name: String
    let filename: String
}

struct Medal: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let requiredMinutes: Int
}

struct AppTheme: Identifiable, Equatable {
    let id: String
    let name: String
    
    let accentColorName: String
    let textColorName: String
    let secondTextColorName: String
    
    let backColor1: String
    let backColor2: String
    let backColor3: String
    let backColor4: String
    let backImage: String
    
    let gradient: LinearGradient
    
    var accentColor: Color { Color(accentColorName) }
    var textColor: Color { Color(textColorName) }
    var secondTextColor: Color { Color(secondTextColorName) }
    
    static func == (lhs: AppTheme, rhs: AppTheme) -> Bool {
        return lhs.id == rhs.id
    }
}

@Observable
class UserManager {
    static let shared = UserManager()
    let freeDailyLimit = 6
    
    var isSleepModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSleepModeEnabled, forKey: "isSleepModeEnabled")
        }
    }
    
    private init() {
        self.isSleepModeEnabled = UserDefaults.standard.bool(forKey: "isSleepModeEnabled")
    }
    
    var isPremium: Bool {
        get { UserDefaults.standard.bool(forKey: "isPremium") }
        set { UserDefaults.standard.set(newValue, forKey: "isPremium") }
    }
    
    
    var selectedSoundID: String {
        get { UserDefaults.standard.string(forKey: "selectedSoundID") ?? "rain" }
        set { UserDefaults.standard.set(newValue, forKey: "selectedSoundID") }
    }
    
    var selectedThemeID: String = UserDefaults.standard.string(forKey: "selectedThemeID") ?? "blue" {
        didSet { UserDefaults.standard.set(selectedThemeID, forKey: "selectedThemeID") }
    }
    
    let themes: [AppTheme] = [
        AppTheme(
            id: "blue",
            name: "Sky Blue",
            accentColorName: "BlueAccentColor",
            textColorName: "BlueTextColor",
            secondTextColorName: "BlueSecondColor",
            backColor1: "BlueBackColor1",
            backColor2: "BlueBackColor2",
            backColor3: "BlueBackColor3",
            backColor4: "BlueBackColor4",
            backImage: "BlueBackImage",
            gradient: LinearGradient(colors: [Color("BlueBackColor1"), Color("BlueBackColor4")], startPoint: .top, endPoint: .bottom)
        ),
        AppTheme(
            id: "purple",
            name: "Lavender",
            accentColorName: "PurpleAccentColor",
            textColorName: "PurpleTextColor",
            secondTextColorName: "PurpleSecondColor",
            backColor1: "PurpleBackColor1",
            backColor2: "PurpleBackColor2",
            backColor3: "PurpleBackColor3",
            backColor4: "PurpleBackColor4",
            backImage: "PurpleBackImage",
            gradient: LinearGradient(colors: [Color("PurpleBackColor1"), Color("PurpleBackColor4")], startPoint: .top, endPoint: .bottom)
        ),
        AppTheme(
            id: "yellow",
            name: "Sunset",
            accentColorName: "YellowAccentColor",
            textColorName: "YellowTextColor",
            secondTextColorName: "YellowSecondColor",
            backColor1: "YellowBackColor1",
            backColor2: "YellowBackColor2",
            backColor3: "YellowBackColor3",
            backColor4: "YellowBackColor4",
            backImage: "YellowBackImage",
            gradient: LinearGradient(colors: [Color("YellowBackColor1"), Color("YellowBackColor4")], startPoint: .top, endPoint: .bottom)
        ),
        AppTheme(
            id: "green",
            name: "Forest",
            accentColorName: "GreenAccentColor",
            textColorName: "GreenTextColor",
            secondTextColorName: "GreenSecondColor",
            backColor1: "GreenBackColor1",
            backColor2: "GreenBackColor2",
            backColor3: "GreenBackColor3",
            backColor4: "GreenBackColor4",
            backImage: "GreenBackImage",
            gradient: LinearGradient(colors: [Color("GreenBackColor1"), Color("GreenBackColor4")], startPoint: .top, endPoint: .bottom)
        ),
        AppTheme(
            id: "white",
            name: "Midnight",
            accentColorName: "WhiteAccentColor",
            textColorName: "WhiteTextColor",
            secondTextColorName: "WhiteSecondColor",
            backColor1: "WhiteBackColor1",
            backColor2: "WhiteBackColor2",
            backColor3: "WhiteBackColor3",
            backColor4: "WhiteBackColor4",
            backImage: "WhiteBackImage",
            gradient: LinearGradient(colors: [Color("WhiteBackColor1"), Color("WhiteBackColor4")], startPoint: .top, endPoint: .bottom)
        ),
        AppTheme(
            id: "deepblue",
            name: "Deep Sea",
            accentColorName: "DeepAccentColor",
            textColorName: "DeepTextColor",
            secondTextColorName: "DeepSecondColor",
            backColor1: "DeepBackColor1",
            backColor2: "DeepBackColor2",
            backColor3: "DeepBackColor3",
            backColor4: "DeepBackColor4",
            backImage: "DeepBackImage",
            gradient: LinearGradient(colors: [Color("WhiteBackColor1"), Color("WhiteBackColor4")], startPoint: .top, endPoint: .bottom)
        )
    ]
    
    let sounds: [AppSound] = [
        AppSound(id: "silence", name: "Silence", filename: ""),
        AppSound(id: "rain", name: "Rain", filename: "rain"),
        AppSound(id: "fire", name: "Fireplace", filename: "fire"),
        AppSound(id: "forest", name: "Forest", filename: "forest"),
        AppSound(id: "night", name: "Night", filename: "night"),
        AppSound(id: "waves", name: "Ocean", filename: "waves"),
        AppSound(id: "white_noise", name: "White Noise", filename: "whitenoise")
    ]
    
    let medals: [Medal] = [
        Medal(id: "first_step", name: "First Step", description: "Complete your first 10 minutes", icon: "figure.step.training", requiredMinutes: 10),
        Medal(id: "thinker", name: "Thinker", description: "Accumulate 60 minutes of focus", icon: "brain.head.profile", requiredMinutes: 60),
        Medal(id: "zen_master", name: "Zen Master", description: "Reach 300 minutes total (5 hours)", icon: "mountain.2.fill", requiredMinutes: 300),
        Medal(id: "week_streak", name: "Week Streak", description: "Pause for 7 days in a row", icon: "flame.fill", requiredMinutes: 0),
        Medal(id: "early_bird", name: "Early Bird", description: "Complete a pause between 6 AM and 9 AM", icon: "sunrise.fill", requiredMinutes: 0),
        Medal(id: "night_owl", name: "Night Owl", description: "Complete a pause after 10 PM", icon: "moon.stars.fill", requiredMinutes: 0),
        Medal(id: "supporter", name: "Supporter", description: "Support Calm by going Plus", icon: "heart.fill", requiredMinutes: 0),
        Medal(id: "marathoner", name: "Marathoner", description: "Complete a single 30-minute session", icon: "figure.run", requiredMinutes: 0),
        Medal(id: "guru", name: "Guru", description: "Reach 1000 minutes of total peace", icon: "star.circle.fill", requiredMinutes: 1000),
        Medal(id: "consistent", name: "Consistent", description: "Pause for 3 days in a row", icon: "checkmark.seal.fill", requiredMinutes: 0)
    ]
    
    func isMedalUnlocked(_ medal: Medal) -> Bool {
        let totalMin = HistoryManager.shared.totalLifetimeMinutes
        let streak = HistoryManager.shared.currentStreak
        let sessions = HistoryManager.shared.history
        
        switch medal.id {
        case "first_step":
            return totalMin >= 10
            
        case "thinker":
            return totalMin >= 60
            
        case "zen_master":
            return totalMin >= 300
            
        case "guru":
            return totalMin >= 1000
            
        case "week_streak":
            return streak >= 7
            
        case "consistent":
            return streak >= 3
            
        case "supporter":
            return isPremium
            
        case "early_bird":
            return sessions.contains { session in
                let hour = Calendar.current.component(.hour, from: session.date)
                return hour >= 6 && hour < 9
            }
            
        case "night_owl":
            return sessions.contains { session in
                let hour = Calendar.current.component(.hour, from: session.date)
                return hour >= 22 || hour < 4
            }
            
        case "marathoner":
            return sessions.contains { session in
                return session.durationMinutes >= 30
            }
            
        default:
            return totalMin >= medal.requiredMinutes && medal.requiredMinutes > 0
        }
    }
    
    func getEarnedMedals() -> [Medal] {
        return medals.filter { isMedalUnlocked($0) }
    }
    
    func getCurrentTheme() -> AppTheme {
        themes.first { $0.id == selectedThemeID } ?? themes[0]
    }
    
    func getCurrentSound() -> AppSound {
        sounds.first { $0.id == selectedSoundID } ?? sounds[0]
    }
    
    func getUserLevel() -> String {
        let totalMin = HistoryManager.shared.totalLifetimeMinutes
        if totalMin < 60 { return "Novice" }
        else if totalMin < 300 { return "Thinker" }
        else { return "Guru" }
    }
    
    func resetSubscription() { isPremium = false }
    func buyPremium() { isPremium = true }
}
