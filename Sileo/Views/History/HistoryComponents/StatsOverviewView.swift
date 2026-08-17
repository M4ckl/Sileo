import SwiftUI

struct StatsOverviewView: View {
    let date: Date
    let stats: DailyData
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(date.formatted(.dateTime.day().month(.wide)))
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            
            Spacer()
            
            HStack(spacing: 0) {
                VStack(spacing: 2) {
                    Text("\(stats.totalMinutes)")
                        .font(.system(size: 44, weight: .light, design: .rounded))
                        .foregroundColor(theme.accentColor)
                        .contentTransition(.numericText())
                    
                    Text("min")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.6))
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity)
                
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color.gray.opacity(0.15))
                    .frame(width: 2, height: 50)
                
                VStack(spacing: 2) {
                    Text("\(stats.sessionsCount)")
                        .font(.system(size: 44, weight: .light, design: .rounded))
                        .foregroundColor(theme.textColor)
                        .contentTransition(.numericText())
                    
                    Text("pauses")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.secondary.opacity(0.6))
                        .textCase(.uppercase)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.bottom, 10)
            
            Spacer()
        }
    }
}
