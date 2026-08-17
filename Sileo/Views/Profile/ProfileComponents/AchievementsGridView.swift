import SwiftUI

struct AchievementsGridView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(GamificationViewModel.self) var gamingManager
    @Environment(SettingsViewModel.self) var settingManager
    
    var isDarkMode: Bool
    var currentScheme: ColorScheme { isDarkMode ? .dark : .light }
    var theme: AppTheme { settingManager.getCurrentTheme() }
    
    @Namespace private var animationNamespace
    @State private var selectedMedal: Medal?
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView(theme: settingManager.getCurrentTheme())
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                    .opacity(selectedMedal == nil ? 1 : 0)
                
                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Medal.all) { medal in
                            let isUnlocked = gamingManager.isMedalUnlocked(medal)
                            
                            if selectedMedal?.id != medal.id {
                                Button(action: {
                                    withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                                        selectedMedal = medal
                                    }
                                }) {
                                    AchievementCard(medal: medal, isUnlocked: isUnlocked, theme: theme)
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
        let isUnlocked = gamingManager.isMedalUnlocked(medal)
        
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
                .transition(.opacity)
            
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

                    AchievementCard(medal: medal, isUnlocked: isUnlocked, theme: theme, isDetail: true)
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
