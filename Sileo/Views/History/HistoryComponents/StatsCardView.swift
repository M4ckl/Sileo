import SwiftUI

struct StatsCardView: View {
    @Binding var currentStatsPage: Int
    let selectedDate: Date
    let stats: DailyData
    let theme: AppTheme
    let colorScheme: ColorScheme
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
                .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
            
            VStack(spacing: 0) {
                TabView(selection: $currentStatsPage) {
                    StatsOverviewView(date: selectedDate, stats: stats, theme: theme)
                        .tag(0)
                    
                    SessionsGraphView(stats: stats, theme: theme)
                        .tag(1)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.3), value: currentStatsPage)
                
                HStack(spacing: 6) {
                    ForEach(0..<2) { index in
                        Capsule()
                            .fill(currentStatsPage == index ? theme.accentColor : Color.gray.opacity(0.3))
                            .frame(width: currentStatsPage == index ? 20 : 6, height: 6)
                            .animation(.spring(), value: currentStatsPage)
                    }
                }
                .padding(.bottom, 12)
            }
        }
        .frame(height: 180)
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.3), value: selectedDate)
    }
}
