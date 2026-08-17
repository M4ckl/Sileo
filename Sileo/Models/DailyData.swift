import Foundation
import SwiftData

@Model
class DailyData {
    @Attribute(.unique) var dateString: String
    
    var date: Date
    var totalMinutes: Int
    var sessionsCount: Int
    
    @Relationship(deleteRule: .cascade, inverse: \PauseSession.dailyData)
    var sessions: [PauseSession]
    
    init(dateString: String, date: Date, totalMinutes: Int = 0, sessionsCount: Int = 0, sessions: [PauseSession] = []) {
        self.dateString = dateString
        self.date = date
        self.totalMinutes = totalMinutes
        self.sessionsCount = sessionsCount
        self.sessions = sessions
    }
}
