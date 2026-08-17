import SwiftUI

struct CalendarCardView: View {
    @Binding var currentMonth: Date
    @Binding var selectedDate: Date
    let monthsList: [Date]
    let theme: AppTheme
    let colorScheme: ColorScheme
    
    private let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.gray.opacity(0.5))
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 20)
            .padding(.horizontal, 20)
            
            TabView(selection: $currentMonth) {
                ForEach(monthsList, id: \.self) { monthDate in
                    MonthGridView(
                        month: monthDate,
                        theme: theme,
                        selectedDate: $selectedDate,
                        currentMonth: $currentMonth
                    )
                    .tag(monthDate)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
        .cornerRadius(30)
        .padding(.horizontal, 20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
        .frame(height: 340)
    }
}
