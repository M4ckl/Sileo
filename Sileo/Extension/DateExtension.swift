import Foundation

extension Date {
    // Получаем ровно 42 дня (6 недель) для стабильной сетки
    func getAllMonthDates() -> [Date] {
        let calendar = Calendar.current
        
        // Получаем компоненты текущего месяца
        let components = calendar.dateComponents([.year, .month], from: self)
        guard let startOfMonth = calendar.date(from: components) else { return [] }
        
        // Определяем день недели первого дня месяца
        let dayOfWeek = calendar.component(.weekday, from: startOfMonth)
        
        // Вычисляем смещение назад, чтобы начать с правильного дня недели
        // (Для США 1=Вс, для других 2=Пн. Этот код универсален)
        let offset = (dayOfWeek - calendar.firstWeekday + 7) % 7
        guard let startGrid = calendar.date(byAdding: .day, value: -offset, to: startOfMonth) else { return [] }
        
        // Генерируем 42 даты
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
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: self)
    }
}
