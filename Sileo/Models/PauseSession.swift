import Foundation
import SwiftData

@Model
class PauseSession {
    var id: UUID
    var date: Date
    var durationMinutes: Int
    
    var dailyData: DailyData?
    
    init(id: UUID = UUID(), date: Date, durationMinutes: Int) {
        self.id = id
        self.date = date
        self.durationMinutes = durationMinutes
    }
}
