import Foundation
import SwiftData
import Observation

@MainActor
@Observable
class HistoryViewModel {
    static let shared = HistoryViewModel()

    var currentDate: Date { Date() }
    
    private(set) var totalLifetimeMinutes: Int = 0
    private(set) var currentStreak: Int = 0

    private let container: ModelContainer
    private let context: ModelContext

    private static let keyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private init() {
        do {
            container = try ModelContainer(for: DailyData.self, PauseSession.self)
            context = ModelContext(container)
        } catch {
            fatalError("Failed to initialize SwiftData: \(error.localizedDescription)")
        }
        
        loadInitialStats()
    }

    private func dateKey(for date: Date) -> String {
        Self.keyFormatter.string(from: date)
    }
    
    func getData(for date: Date) -> DailyData {
        let dateStr = dateKey(for: date)
        
        let descriptor = FetchDescriptor<DailyData>(predicate: #Predicate { $0.dateString == dateStr })
        
        if let fetchedDay = try? context.fetch(descriptor).first {
            return fetchedDay
        }
        
        let newDay = DailyData(dateString: dateStr, date: date)
        context.insert(newDay)
        try? context.save()
        
        return newDay
    }
    
    func addSession(minutes: Int) {
        let now = Date()
        let todayData = getData(for: now)
        
        let newSession = PauseSession(date: now, durationMinutes: minutes)
        
        todayData.sessions.append(newSession)
        todayData.totalMinutes += minutes
        todayData.sessionsCount += 1
        
        try? context.save()
        
        totalLifetimeMinutes += minutes
        calculateStreak()
    }

    func clearAll() {
        try? context.delete(model: DailyData.self)
        try? context.save()
        
        totalLifetimeMinutes = 0
        currentStreak = 0
    }
    
    private func loadInitialStats() {
        let descriptor = FetchDescriptor<DailyData>()
        if let allDays = try? context.fetch(descriptor) {
            totalLifetimeMinutes = allDays.reduce(0) { $0 + $1.totalMinutes }
        }
        
        calculateStreak()
    }
    
    private func calculateStreak() {
        var streak = 0
        let calendar = Calendar.current
        var checkDate = Date()
        
        if getData(for: checkDate).totalMinutes == 0 {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
        }
        
        while true {
            let data = getData(for: checkDate)
            
            if data.totalMinutes > 0 {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? checkDate
            } else {
                break
            }
        }
        
        self.currentStreak = streak
    }
    
    func getAllSessions() -> [PauseSession] {
        // Просим базу данных выдать вообще все сессии, которые в ней есть
        let descriptor = FetchDescriptor<PauseSession>()
        return (try? context.fetch(descriptor)) ?? []
    }
}
