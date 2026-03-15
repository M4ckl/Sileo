import SwiftUI

struct ProfileContentView: View {
    @Binding var isDarkMode: Bool
    
    @Binding var navigateToAchievements: Bool
    @Binding var navigateToPaywall: Bool
    @Binding var navigateToManageSubscription: Bool
    @Binding var showSounds: Bool
    @Binding var showThemes: Bool
    
    let theme: AppTheme
    var dismissAction: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(UserManager.self) var userManager
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer().frame(height: 20)
                
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 0) {
                        HStack(spacing: 20) {
                            ZStack {
                                Circle().fill(theme.accentColor.opacity(0.1)).frame(width: 80, height: 80)
                                Image(userManager.isPremium ? "calmplus" : "calm")
                                    .resizable().renderingMode(.template)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(theme.accentColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .center, spacing: 8) {
                                    Text(userManager.getUserLevel())
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(theme.textColor)
                                    
                                    Text(userManager.isPremium ? "CALM PLUS" : "CALM")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.white)
                                        .padding(.vertical, 4).padding(.horizontal, 8)
                                        .background(userManager.isPremium ? theme.accentColor : Color.black.opacity(0.2))
                                        .clipShape(Capsule())
                                }
                                
                                Text("\(HistoryManager.shared.totalLifetimeMinutes) min total")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(24)
                        
                        Capsule().fill(Color.gray.opacity(0.1)).frame(height: 2).padding(.horizontal, 20)
                        
                        Button(action: { navigateToAchievements = true }) {
                            SettingsRow(icon: "trophy.fill", title: "Achievements", value: "", theme: theme)
                        }
                    }
                    .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
                    .cornerRadius(30)
                    .padding(.horizontal, 20)
                    
                    // Settings
                    VStack(spacing: 0) {
                        Button(action: { showSounds = true }) {
                            SettingsRow(icon: "speaker.wave.2.fill", title: "Sound", value: userManager.getCurrentSound().name, theme: theme)
                        }
                        Capsule().fill(Color.gray.opacity(0.1)).frame(height: 2).padding(.horizontal, 20)
                        
                        Button(action: { showThemes = true }) {
                            HStack {
                                Image(systemName: "paintpalette.fill").foregroundColor(theme.textColor.opacity(0.3))
                                Text("Theme").font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(theme.textColor)
                                Spacer()
                                HStack(spacing: 8) {
                                    Text(userManager.getCurrentTheme().name).font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(userManager.getCurrentTheme().accentColor)
                                }
                                Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundColor(theme.textColor.opacity(0.3))
                            }
                            .padding(20)
                        }
                    }
                    .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
                    .cornerRadius(30)
                    .padding(.horizontal, 20)
                    
                    // Dark Mode Toggle
                    HStack {
                        Image(systemName: "moon.fill").foregroundColor(theme.textColor.opacity(0.3))
                        Text("Dark Mode").font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(theme.textColor)
                        Spacer()
                        Toggle("", isOn: $isDarkMode)
                            .toggleStyle(SwitchToggleStyle(tint: theme.accentColor))
                            .labelsHidden()
                    }
                    .padding(.vertical, 14).padding(.horizontal, 20)
                    .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
                    .cornerRadius(30)
                    .padding(.horizontal, 20)
                    
                    // Subscription
                    if !userManager.isPremium {
                        Button(action: { navigateToPaywall = true }) {
                            HStack {
                                Text("Upgrade to Calm Plus").font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(theme.textColor)
                                Spacer()
                                Text("$0.99").font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(theme.textColor.opacity(0.3))
                            }
                            .padding(20)
                            .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
                            .cornerRadius(30)
                            .padding(.horizontal, 20)
                        }
                    } else {
                        Button(action: { navigateToManageSubscription = true }) {
                            HStack {
                                Text("Manage Subscription").font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(theme.textColor)
                                Spacer()
                                Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundColor(theme.textColor.opacity(0.3))
                            }
                            .padding(20)
                            .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 1))
                            .cornerRadius(30)
                            .padding(.horizontal, 20)
                        }
                    }
                }
                
                Spacer(minLength: 0)
                
                // Bottom Bar
                HStack {
                    Button(action: { dismissAction() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left").font(.system(size: 16, weight: .medium))
                            Text("back").font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                        .padding(.vertical, 12).padding(.horizontal, 16)
                        .glassEffect(.clear.interactive()).foregroundStyle(theme.textColor)
                    }
                    Spacer()
                    Text("PROFILE").font(.system(size: 16, weight: .medium, design: .rounded)).tracking(2)
                        .padding(.vertical, 12).padding(.horizontal, 18)
                        .glassEffect(.clear).foregroundStyle(theme.textColor.opacity(0.7))
                }
                .padding(.horizontal, 20).padding(.bottom, 0)
            }
            .safeAreaPadding(.bottom)
        }
    }
}

