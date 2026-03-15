import SwiftUI

struct PauseSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let durationMinutes: Int
}
