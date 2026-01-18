import SwiftUI

struct MonthGridView: View {
    let month: Date
    let theme: AppTheme
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(month.getAllMonthDates(), id: \.self) { date in
                    
                    let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
                    let isToday = calendar.isDateInToday(date)
                    let isCurrentMonth = calendar.isDate(date, equalTo: month, toGranularity: .month)
                    let isFuture = date > Date() && !calendar.isDateInToday(date)
                    
                    ZStack {
                        if isSelected {
                            Circle()
                                .fill(theme.accentColor)
                        } else if isToday {
                            Circle()
                                .stroke(theme.accentColor.opacity(0.5), lineWidth: 1)
                        }
                        
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 18, weight: isSelected ? .bold : .medium, design: .rounded))
                            .foregroundColor(
                                isSelected ? .white :
                                isFuture ? .secondary.opacity(0.2) :
                                    isCurrentMonth ? theme.textColor : .secondary.opacity(0.3)
                            )
                    }
                    .frame(height: 36)
                    .contentShape(Circle())
                    .onTapGesture {
                        if !isFuture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedDate = date
                                if !isCurrentMonth {
                                    // Нормализуем дату на начало месяца
                                    let components = calendar.dateComponents([.year, .month], from: date)
                                    if let newMonthStart = calendar.date(from: components) {
                                        currentMonth = newMonthStart
                                    }
                                }
                            }
                            let generator = UIImpactFeedbackGenerator(style: .light)
                            generator.impactOccurred()
                        } else {
                             UINotificationFeedbackGenerator().notificationOccurred(.error)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
    }
}
