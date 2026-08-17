import SwiftUI

struct HistoryView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(SettingsViewModel.self) var settingManager
    @Environment(HistoryViewModel.self) var historyManager
    
    var theme: AppTheme { settingManager.getCurrentTheme() }
    
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = {
        let components = Calendar.current.dateComponents([.year, .month], from: Date())
        return Calendar.current.date(from: components)!
    }()
    @State private var monthsList: [Date] = []
    
    @State private var showWheelPicker = false
    @State private var currentStatsPage = 0
    
    var stats: DailyData {
        historyManager.getData(for: selectedDate)
    }
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView(theme: theme)
            
            VStack(spacing: 0) {
                Spacer().frame(height: 20)
                
                MonthCarouselView(
                    currentMonth: $currentMonth,
                    monthsList: monthsList,
                    theme: theme,
                    onLongPress: { showWheelPicker = true }
                )
                
                Spacer().frame(height: 12)
                
                CalendarCardView(
                    currentMonth: $currentMonth,
                    selectedDate: $selectedDate,
                    monthsList: monthsList,
                    theme: theme,
                    colorScheme: colorScheme
                )
                
                Spacer().frame(height: 14)
                
                Capsule()
                    .fill(theme.textColor.opacity(0.1))
                    .frame(height: 2)
                    .padding(.horizontal, 40)
                
                Spacer().frame(height: 14)
                
                StatsCardView(
                    currentStatsPage: $currentStatsPage,
                    selectedDate: selectedDate,
                    stats: stats,
                    theme: theme,
                    colorScheme: colorScheme
                )
                
                Spacer(minLength: 0)
                
                headerView
            }
            .safeAreaPadding(.bottom)
        }
        .navigationBarHidden(true)
        .onAppear {
            if monthsList.isEmpty { generateMonths() }
        }
        .sheet(isPresented: $showWheelPicker) {
            WheelPickerSheet(currentMonth: $currentMonth, theme: theme)
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("HISTORY")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .tracking(2)
                .padding(.vertical, 12)
                .padding(.horizontal, 18)
                .glassEffect(.clear)
                .foregroundStyle(theme.textColor.opacity(0.7))
            Spacer()
            Button(action: { dismiss() }) {
                HStack(spacing: 4) {
                    Text("back")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .medium))
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .glassEffect(.clear.interactive())
                .foregroundStyle(theme.textColor)
            }
        }
        .padding(.horizontal, 20)
    }
    
    func generateMonths() {
        let now = Date()
        let calendar = Calendar.current
        guard let start = calendar.date(byAdding: .year, value: -5, to: now),
              let end = calendar.date(byAdding: .year, value: 2, to: now) else { return }
        
        var date = start
        var res: [Date] = []
        
        let components = calendar.dateComponents([.year, .month], from: date)
        date = calendar.date(from: components)!
        
        while date <= end {
            res.append(date)
            date = calendar.date(byAdding: .month, value: 1, to: date)!
        }
        monthsList = res
    }
}
