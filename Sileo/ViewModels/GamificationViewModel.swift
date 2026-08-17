import Foundation
import Observation

@MainActor
@Observable
class GamificationViewModel {
    static let shared = GamificationViewModel()
    
    private init() {}
    
    func isMedalUnlocked(_ medal: Medal) -> Bool {
        let totalMin = HistoryViewModel.shared.totalLifetimeMinutes
        let streak = HistoryViewModel.shared.currentStreak
        let sessions = HistoryViewModel.shared.getAllSessions()
        
        switch medal.id {
        case "first_step": return totalMin >= 10
        case "thinker": return totalMin >= 60
        case "zen_master": return totalMin >= 300
        case "guru": return totalMin >= 1000
        case "week_streak": return streak >= 7
        case "consistent": return streak >= 3
        case "supporter": return true

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
        return Medal.all.filter { isMedalUnlocked($0) }
    }
    
    func getUserLevel() -> String {
        let totalMin = HistoryViewModel.shared.totalLifetimeMinutes
        if totalMin < 60 { return "Novice" }
        else if totalMin < 300 { return "Thinker" }
        else { return "Guru" }
    }
}
