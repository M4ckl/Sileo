import SwiftUI

struct DailyData: Codable {
    var date: Date
    var totalMinutes: Int
    var sessionsCount: Int
    var sessions: [PauseSession] = []
}
