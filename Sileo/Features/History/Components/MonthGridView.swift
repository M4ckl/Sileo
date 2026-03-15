import SwiftUI

struct MonthGridView: View {
    let month: Date
    let theme: AppTheme
    @Binding var selectedDate: Date
    @Binding var currentMonth: Date
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

    private var paddedDays: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month),
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
    
    var body: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(paddedDays.indices, id: \.self) { index in
                    if let date = paddedDays[index] {
                        dayView(for: date)
                    } else {
                        Color.clear.frame(height: 36)
                    }
                }
            }
            .padding(.horizontal, 20)
            Spacer()
        }
    }

    @ViewBuilder
    private func dayView(for date: Date) -> some View {
        let isSelected = calendar.isDate(date, inSameDayAs: selectedDate)
        let isToday = calendar.isDateInToday(date)

        let isFuture = date > Date() && !isToday
        
        ZStack {
            if isSelected {
                Circle().fill(theme.accentColor)
            } else if isToday {
                Circle().stroke(theme.accentColor.opacity(0.5), lineWidth: 1)
            }
            
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 18, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundColor(
                    isSelected ? .white :
                    isFuture ? .secondary.opacity(0.2) : theme.textColor
                )
        }
        .frame(height: 36)
        .contentShape(Circle())
        .onTapGesture {
            if !isFuture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    selectedDate = date
                }
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            } else {
                UINotificationFeedbackGenerator().notificationOccurred(.error)
            }
        }
    }
}
