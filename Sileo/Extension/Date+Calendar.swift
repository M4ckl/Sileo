import Foundation

extension Date {
    
    private static let monthYearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    func getAllMonthDates() -> [Date] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        guard let startOfMonth = calendar.date(from: components) else { return [] }
        
        let dayOfWeek = calendar.component(.weekday, from: startOfMonth)
        let offset = (dayOfWeek - calendar.firstWeekday + 7) % 7
        guard let startGrid = calendar.date(byAdding: .day, value: -offset, to: startOfMonth) else { return [] }
        
        var dates: [Date] = []
        for i in 0..<42 {
            if let date = calendar.date(byAdding: .day, value: i, to: startGrid) {
                dates.append(date)
            }
        }
        return dates
    }

    func isSameMonth(as date: Date) -> Bool {
        Calendar.current.isDate(self, equalTo: date, toGranularity: .month)
    }

    func monthYearString() -> String {
        Self.monthYearFormatter.string(from: self)
    }
    
    func paddedDaysForMonth() -> [Date?] {
        let calendar = Calendar.current
        
        guard let monthInterval = calendar.dateInterval(of: .month, for: self),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: monthInterval.start))
        else { return [] }
        
        let firstWeekday = calendar.component(.weekday, from: firstDayOfMonth)
        
        let emptyOffsets = (firstWeekday + 5) % 7
        
        var days: [Date?] = Array(repeating: nil, count: emptyOffsets)
        
        guard let daysRange = calendar.range(of: .day, in: .month, for: firstDayOfMonth) else { return days }
        
        for dayOffset in 0..<daysRange.count {
            if let realDate = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfMonth) {
                days.append(realDate)
            }
        }
        
        return days
    }
}
