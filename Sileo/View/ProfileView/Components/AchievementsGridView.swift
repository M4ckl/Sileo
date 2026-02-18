import SwiftUI

struct AchievementsGridView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(UserManager.self) var userManager
    
    var isDarkMode: Bool
    var currentScheme: ColorScheme { isDarkMode ? .dark : .light }
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    @Namespace private var animationNamespace
    @State private var selectedMedal: Medal?
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                    .opacity(selectedMedal == nil ? 1 : 0)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(userManager.medals) { medal in
                            let isUnlocked = userManager.isMedalUnlocked(medal)
                            
                            if selectedMedal?.id != medal.id {
                                Button(action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                        selectedMedal = medal
                                    }
                                }) {
                                    AchievementCard(medal: medal, isUnlocked: isUnlocked, theme: theme, forcedScheme: currentScheme)
                                        .matchedGeometryEffect(id: medal.id, in: animationNamespace)
                                }
                            } else {
                                Color.clear.frame(height: 180)
                            }
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 50)
                }
                .opacity(selectedMedal == nil ? 1 : 0)
            }
            if let medal = selectedMedal {
                detailView(for: medal)
            }
        }
        .navigationBarHidden(true)
        .environment(\.colorScheme, currentScheme)
    }
    
    var headerView: some View {
        HStack {
            Button(action: { dismiss() }) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24))
                }
                .foregroundColor(theme.textColor)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .clipShape(Capsule())
                .glassEffect(.clear.interactive())
            }
            Spacer()
            Text("Achievements")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.textColor)
                .textCase(.uppercase)
                .tracking(1)
            Spacer()
            Image(systemName: "chevron.left").opacity(0).padding()
        }
        .padding(.horizontal)
        .padding(.top)
    }
    
    @ViewBuilder
    func detailView(for medal: Medal) -> some View {
        let isUnlocked = userManager.isMedalUnlocked(medal)
        
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .opacity(selectedMedal != nil ? 1 : 0)
            
            VStack(spacing: 0) {
                HStack {
                    Button(action: { closeDetail() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24))
                        }
                        .foregroundColor(theme.textColor)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .clipShape(Capsule())
                        .glassEffect(.clear.interactive())
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(theme.accentColor)
                        .frame(width: 250, height: 250)
                        .blur(radius: 60)
                        .opacity(isUnlocked ? 0.6 : 0)
                    
                    AchievementCard(medal: medal, isUnlocked: isUnlocked, theme: theme, isDetail: true, forcedScheme: currentScheme)
                        .matchedGeometryEffect(id: medal.id, in: animationNamespace)
                        .scaleEffect(1.2)
                        .rotation3DEffect(
                            .degrees(isUnlocked ? 5 : 0),
                            axis: (x: 1.0, y: 1.0, z: 0.0)
                        )
                        .shadow(color: isUnlocked ? theme.accentColor.opacity(0.5) : .black.opacity(0.3), radius: 30, x: 0, y: 15)
                }
                
                Spacer()
                
                VStack(spacing: 16) {
                    Text(medal.name)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(currentScheme == .dark ? .white : Color(theme.textColor))
                    
                    if !isUnlocked {
                        Text("LOCKED")
                            .font(.caption.bold())
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white.opacity(0.8))
                    } else {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("Earned")
                        }
                        .font(.subheadline.bold())
                        .foregroundColor(theme.accentColor.opacity(0.8))
                    }
                    
                    Text(medal.description)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(currentScheme == .dark ? .white : Color(theme.textColor))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .padding(.bottom, 50)
            }
        }
        .zIndex(2)
    }
    
    func closeDetail() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            selectedMedal = nil
        }
    }
}

struct AchievementCard: View {
    let medal: Medal
    let isUnlocked: Bool
    let theme: AppTheme
    var isDetail: Bool = false
    var forcedScheme: ColorScheme
    
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
                    .foregroundColor(isUnlocked ? .white : colorScheme == .dark ? .white : theme.accentColor.opacity(0.6))
                    .grayscale(colorScheme == .dark ? 0 : 1.0)
                    .shadow(
                        color: isUnlocked ? .black.opacity(0.3) : .clear,
                        radius: 4,
                        x: 0,
                        y: 4
                    )
                    .offset(y: isUnlocked ? -2 : 0)
            }
            .opacity(isUnlocked ? 1 : 0.6)
            
            if !isDetail {
                Text(medal.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(isUnlocked ? theme.textColor : (forcedScheme == .dark ? .white.opacity(0.6) : .gray))
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
                .fill(Color.white.opacity(forcedScheme == .dark ? 0.1 : 1))
                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
    }
}
