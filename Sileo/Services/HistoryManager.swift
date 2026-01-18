import SwiftUI

// --- МОДЕЛИ ДАННЫХ ---

struct PauseSession: Codable, Identifiable {
    let id: UUID
    let date: Date           // Точное время завершения
    let durationMinutes: Int // Длительность
}

struct DailyData: Codable {
    var date: Date
    var totalMinutes: Int
    var sessionsCount: Int
    var sessions: [PauseSession] = []
}

// --- МЕНЕДЖЕР ---

@Observable
class HistoryManager {
    static let shared = HistoryManager()
    
    // Свойство currentDate больше не нужно, используем Date() напрямую
    // или можно оставить для удобства как:
    var currentDate: Date { Date() }
    
    var history: [PauseSession] {
        let keys = UserDefaults.standard.dictionaryRepresentation().keys.filter { $0.hasPrefix("history_") }
        var allSessions: [PauseSession] = []
        
        for key in keys {
            if let data = UserDefaults.standard.data(forKey: key),
               let record = try? JSONDecoder().decode(DailyData.self, from: data) {
                allSessions.append(contentsOf: record.sessions)
            }
        }
        return allSessions.sorted { $0.date > $1.date }
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var totalLifetimeMinutes: Int {
        let keys = UserDefaults.standard.dictionaryRepresentation().keys.filter { $0.hasPrefix("history_") }
        var total = 0
        for key in keys {
            if let data = UserDefaults.standard.data(forKey: key),
               let record = try? JSONDecoder().decode(DailyData.self, from: data) {
                total += record.totalMinutes
            }
        }
        return total
    }
    
    var currentStreak: Int {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = Date() // Берем текущую дату
        
        while true {
            let data = getData(for: checkDate)
            if data.totalMinutes > 0 {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        return streak
    }
    
    // --- ЛОГИКА ---
    
    func getData(for date: Date) -> DailyData {
        let key = "history_" + dateKey(for: date)
        if let data = UserDefaults.standard.data(forKey: key),
           let record = try? JSONDecoder().decode(DailyData.self, from: data) {
            return record
        }
        return DailyData(date: date, totalMinutes: 0, sessionsCount: 0, sessions: [])
    }
    
    func addSession(minutes: Int) {
        let now = Date() // Реальное время
        let key = "history_" + dateKey(for: now)
        var currentData = getData(for: now)
        
        let newSession = PauseSession(
            id: UUID(),
            date: now,
            durationMinutes: minutes
        )
        
        currentData.totalMinutes += minutes
        currentData.sessionsCount += 1
        currentData.sessions.append(newSession)
        
        if let encoded = try? JSONEncoder().encode(currentData) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func clearAll() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}
