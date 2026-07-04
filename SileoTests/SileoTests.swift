import Testing
import Foundation
@testable import Sileo

// MARK: - Date Extension

struct DateExtensionTests {

    /// Сетка месяца всегда должна содержать ровно 42 дня (6 недель по 7 дней).
    @Test func monthGridAlwaysHas42Days() {
        let dates = Date().getAllMonthDates()
        #expect(dates.count == 42)
    }

    /// Сетка должна начинаться с первого дня недели согласно текущему календарю.
    @Test func monthGridStartsOnFirstWeekday() throws {
        let calendar = Calendar.current
        // Берём фиксированную дату: 15 марта 2026.
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

    /// Добавление сессии должно увеличивать историю и суммарное время.
    @Test func addSessionUpdatesHistoryAndTotals() {
        let manager = HistoryManager.shared
        manager.clearAll()

        manager.addSession(minutes: 10)
        manager.addSession(minutes: 5)

        #expect(manager.history.count == 2)
        #expect(manager.totalLifetimeMinutes == 15)

        // Данные за сегодня должны агрегироваться корректно.
        let today = manager.getData(for: Date())
        #expect(today.totalMinutes == 15)
        #expect(today.sessionsCount == 2)

        manager.clearAll()
    }

    /// clearAll должен полностью обнулять состояние.
    @Test func clearAllResetsState() {
        let manager = HistoryManager.shared
        manager.addSession(minutes: 20)

        manager.clearAll()

        #expect(manager.history.isEmpty)
        #expect(manager.totalLifetimeMinutes == 0)
        #expect(manager.currentStreak == 0)
    }
}
