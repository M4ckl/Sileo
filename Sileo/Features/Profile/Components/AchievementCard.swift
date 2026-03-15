import SwiftUI

struct AchievementCard: View {
    let medal: Medal
    let isUnlocked: Bool
    let theme: AppTheme
    var isDetail: Bool = false
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Group {
                    if isUnlocked {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [theme.accentColor.opacity(0.8), theme.accentColor],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.3), .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .padding(2)
                                .blur(radius: 2)
                            
                            Circle()
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [.white.opacity(0.6), theme.accentColor.opacity(0.0)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: isDetail ? 4 : 2
                                )
                        }
                    } else {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.05))
                            
                            Circle()
                                .strokeBorder(
                                    colorScheme == .dark ? .white.opacity(0.3) : theme.accentColor.opacity(0.3),
                                    lineWidth: isDetail ? 3 : 2
                                )
                        }
                        .grayscale(colorScheme == .dark ? 0 : 1.0)
                    }
                }
                .frame(width: isDetail ? 200 : 80, height: isDetail ? 200 : 80)
                .shadow(
                    color: isUnlocked ? theme.accentColor.opacity(0.4) : .black.opacity(0.1),
                    radius: isDetail ? 20 : 8,
                    x: 0,
                    y: isDetail ? 10 : 4
                )
                
                Image(systemName: medal.icon)
                    .font(.system(size: isDetail ? 80 : 36))
                    .foregroundColor(isUnlocked ? .white : (colorScheme == .dark ? .white : theme.accentColor.opacity(0.6)))
                    .grayscale(colorScheme == .dark ? 0 : 1.0)
                    .shadow(
                        color: isUnlocked ? .black.opacity(0.3) : .clear,
                        radius: 4, x: 0, y: 4
                    )
                    .offset(y: isUnlocked ? -2 : 0)
            }
            .opacity(isUnlocked ? 1 : 0.6)
            
            if !isDetail {
                Text(medal.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(isUnlocked ? theme.textColor : (colorScheme == .dark ? .white.opacity(0.6) : .gray))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .frame(height: isDetail ? 250 : 180)
        .background(
            isDetail ? nil :
                RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}
