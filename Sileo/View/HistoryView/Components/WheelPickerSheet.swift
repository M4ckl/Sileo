import SwiftUI

struct WheelPickerSheet: View {
    @Binding var currentMonth: Date
    @Environment(\.dismiss) var dismiss
    private let calendar = Calendar.current
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Select Month")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(theme.textColor)
                .padding(.top, 25)
            
            HStack(spacing: 0) {
                Picker("Month", selection: Binding(
                    get: { calendar.component(.month, from: currentMonth) },
                    set: { newMonth in
                        updateDate(newMonth: newMonth, newYear: nil)
                    }
                )) {
                    ForEach(1...12, id: \.self) { month in
                        Text(calendar.monthSymbols[month - 1].capitalized).tag(month)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
                
                Picker("Year", selection: Binding(
                    get: { calendar.component(.year, from: currentMonth) },
                    set: { newYear in
                        updateDate(newMonth: nil, newYear: newYear)
                    }
                )) {
                    let currentYear = calendar.component(.year, from: HistoryManager.shared.currentDate)
                    // Диапазон: 5 лет назад - текущий
                    ForEach((currentYear - 5)...currentYear, id: \.self) { year in
                        Text(String(format: "%d", year)).tag(year)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .padding(.horizontal)

            Button(action: { dismiss() }) {
                Text("Done")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(theme.accentColor)
                    .cornerRadius(16)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .presentationDetents([.height(350)])
        .presentationDragIndicator(.visible)
    }
    
    func updateDate(newMonth: Int?, newYear: Int?) {
        var components = calendar.dateComponents([.year, .month, .day], from: currentMonth)
        if let m = newMonth { components.month = m }
        if let y = newYear { components.year = y }
        components.day = 1
        
        if let newDate = calendar.date(from: components), newDate <= HistoryManager.shared.currentDate {
            currentMonth = newDate
        } else {
            // Если будущее — макс. доступная дата
            currentMonth = HistoryManager.shared.currentDate
        }
    }
}
