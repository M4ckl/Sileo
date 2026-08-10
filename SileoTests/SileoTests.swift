import Testing
import Foundation
@testable import Sileo

// MARK: - Date Extension
struct DateExtensionTests {
    @Test func monthGridAlwaysHas42Days() {
        let dates = Date().getAllMonthDates()
        #expect(dates.count == 42)
    }

    @Test func monthGridStartsOnFirstWeekday() throws {
        let calendar = Calendar.current
        let components = DateComponents(year: 2026, month: 3, day: 15)
        let date = try #require(calendar.date(from: components))

        let dates = date.getAllMonthDates()
        let firstDate = try #require(dates.first)

        let weekday = calendar.component(.weekday, from: firstDate)
        #expect(weekday == calendar.firstWeekday)
    }

    @Test func isSameMonthDistinguishesMonths() throws {
        let calendar = Calendar.current
        let march = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 1)))
        let marchLater = try #require(calendar.date(from: DateComponents(year: 2026, month: 3, day: 28)))
        let april = try #require(calendar.date(from: DateComponents(year: 2026, month: 4, day: 1)))
        let marchNextYear = try #require(calendar.date(from: DateComponents(year: 2027, month: 3, day: 1)))

        #expect(march.isSameMonth(as: marchLater))
        #expect(!march.isSameMonth(as: april))
        #expect(!march.isSameMonth(as: marchNextYear))
    }
}

// MARK: - HistoryManager
@MainActor
struct HistoryManagerTests {

    @Test func addSessionUpdatesHistoryAndTotals() {
        let manager = HistoryManager.shared
        manager.clearAll()

        manager.addSession(minutes: 10)
        manager.addSession(minutes: 5)

        #expect(manager.history.count == 2)
        #expect(manager.totalLifetimeMinutes == 15)

        let today = manager.getData(for: Date())
        #expect(today.totalMinutes == 15)
        #expect(today.sessionsCount == 2)

        manager.clearAll()
    }

    @Test func clearAllResetsState() {
        let manager = HistoryManager.shared
        manager.addSession(minutes: 20)

        manager.clearAll()

        #expect(manager.history.isEmpty)
        #expect(manager.totalLifetimeMinutes == 0)
        #expect(manager.currentStreak == 0)
    }
}
