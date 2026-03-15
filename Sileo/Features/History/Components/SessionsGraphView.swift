import SwiftUI

struct SessionsGraphView: View {
    let stats: DailyData
    let theme: AppTheme
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Sessions Timeline")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            
            if stats.sessions.isEmpty {
                Spacer()
                Text("No data")
                    .font(.system(size: 14, design: .rounded))
                    .foregroundStyle(.secondary.opacity(0.5))
                Spacer()
            } else {
                HStack(alignment: .bottom, spacing: 10) {
                    VStack(alignment: .trailing, spacing: 0) {
                        Text("60m").font(.system(size: 9, weight: .bold)).foregroundColor(.gray.opacity(0.5))
                        Spacer()
                        Text("30m").font(.system(size: 9, weight: .bold)).foregroundColor(.gray.opacity(0.5))
                        Spacer()
                        Text("0m").font(.system(size: 9, weight: .bold)).foregroundColor(.gray.opacity(0.5))
                    }
                    .frame(height: 80)
                    .padding(.bottom, 16)
                    
                    ZStack(alignment: .bottom) {
                        VStack {
                            Divider().background(Color.gray.opacity(0.1))
                            Spacer()
                            Divider().background(Color.gray.opacity(0.1))
                            Spacer()
                            Divider().background(Color.gray.opacity(0.1))
                        }
                        .frame(height: 80)
                        .padding(.bottom, 16)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .bottom, spacing: 12) {
                                ForEach(Array(stats.sessions.enumerated()), id: \.offset) { index, session in
                                    VStack(spacing: 4) {
                                        ZStack(alignment: .bottom) {
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(Color.gray.opacity(0.05))
                                                .frame(width: 16, height: 80)
                                            
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(theme.accentColor)
                                                .frame(width: 16, height: heightForBar(minutes: session.durationMinutes, maxHeight: 80))
                                        }
                                        
                                        Text("\(index + 1)")
                                            .font(.system(size: 9, weight: .bold))
                                            .foregroundColor(.gray.opacity(0.5))
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
            Spacer()
        }
    }
    
    private func heightForBar(minutes: Int, maxHeight: CGFloat) -> CGFloat {
        let maxMinutes: CGFloat = 60
        let normalizedMinutes = min(CGFloat(minutes), maxMinutes)
        let height = (normalizedMinutes / maxMinutes) * maxHeight
        return max(4, height)
    }
}
