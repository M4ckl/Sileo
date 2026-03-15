import SwiftUI
import Observation

@Observable
class HistoryManager {
    static let shared = HistoryManager()
    
    var currentDate: Date { Date() }
    
    private(set) var history: [PauseSession] = []
    private(set) var totalLifetimeMinutes: Int = 0
    private(set) var currentStreak: Int = 0

    private var dailyDataCache: [String: DailyData] = [:]
    
    private init() {
        loadEverythingFromDisk()
    }
    
    private func dateKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // MARK: - Core Logic
    func getData(for date: Date) -> DailyData {
        let key = "history_" + dateKey(for: date)

        if let cached = dailyDataCache[key] {
            return cached
        }
        
        if let data = UserDefaults.standard.data(forKey: key),
           let record = try? JSONDecoder().decode(DailyData.self, from: data) {
            dailyDataCache[key] = record
            return record
        }
        
        return DailyData(date: date, totalMinutes: 0, sessionsCount: 0, sessions: [])
    }
    
    func addSession(minutes: Int) {
        let now = Date()
        let key = "history_" + dateKey(for: now)
        var currentData = getData(for: now)
        
        let newSession = PauseSession(id: UUID(), date: now, durationMinutes: minutes)

        currentData.totalMinutes += minutes
        currentData.sessionsCount += 1
        currentData.sessions.append(newSession)

        dailyDataCache[key] = currentData

        if let encoded = try? JSONEncoder().encode(currentData) {
            UserDefaults.standard.set(encoded, forKey: key)
        }

        history.insert(newSession, at: 0)
        history.sort { $0.date > $1.date }
        
        totalLifetimeMinutes += minutes
        calculateStreak()
    }

    func clearAll() {
        let keys = UserDefaults.standard.dictionaryRepresentation().keys.filter { $0.hasPrefix("history_") }
        for key in keys {
            UserDefaults.standard.removeObject(forKey: key)
        }

        dailyDataCache.removeAll()
        history.removeAll()
        totalLifetimeMinutes = 0
        currentStreak = 0
    }
    
    // MARK: - Private Helpers
    private func loadEverythingFromDisk() {
        let keys = UserDefaults.standard.dictionaryRepresentation().keys.filter { $0.hasPrefix("history_") }
        var allSessions: [PauseSession] = []
        var total = 0
        
        for key in keys {
            if let data = UserDefaults.standard.data(forKey: key),
               let record = try? JSONDecoder().decode(DailyData.self, from: data) {
                
                dailyDataCache[key] = record
                allSessions.append(contentsOf: record.sessions)
                total += record.totalMinutes
            }
        }
        self.history = allSessions.sorted { $0.date > $1.date }
        self.totalLifetimeMinutes = total
        self.calculateStreak()
    }
    
    private func calculateStreak() {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = Date()
        
        while true {
            let data = getData(for: checkDate)
            if data.totalMinutes > 0 {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                if calendar.isDateInToday(checkDate) {
                    checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
                    let yesterdayData = getData(for: checkDate)
                    if yesterdayData.totalMinutes == 0 {
                        break
                    }
                } else {
                    break
                }
            }
        }
        self.currentStreak = streak
    }
}
