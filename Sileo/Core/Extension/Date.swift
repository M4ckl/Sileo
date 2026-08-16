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
}
