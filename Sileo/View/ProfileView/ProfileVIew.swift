import SwiftUI
import PhotosUI

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(UserManager.self) var userManager
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    var body: some View {
        ZStack {
            InternalProfileContent(
                isDarkMode: $isDarkMode,
                dismissAction: { dismiss() },
                forceScheme: .light
            )
            .environment(userManager)
            .opacity(isDarkMode ? 0 : 1)
            
            InternalProfileContent(
                isDarkMode: $isDarkMode,
                dismissAction: { dismiss() },
                forceScheme: .dark
            )
            .environment(userManager)
            .opacity(isDarkMode ? 1 : 0)
        }
        .animation(.easeInOut(duration: 0.5), value: isDarkMode)
        .navigationBarHidden(true)
    }
}

struct InternalProfileContent: View {
    @Binding var isDarkMode: Bool
    var dismissAction: () -> Void
    var forceScheme: ColorScheme
    
    @Environment(UserManager.self) var userManager
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    @State private var navigateToAchievements = false
    @State private var navigateToPaywall = false
    @State private var navigateToManageSubscription = false
    @State private var showSounds = false
    @State private var showThemes = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                BackgroundOnlyColorsView()
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    Spacer().frame(height: 20)
                    
                    // КОНТЕНТ
                    VStack(spacing: 16) {
                        
                        VStack(spacing: 0) {
                            HStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .fill(theme.accentColor.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 40))
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
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .background(
                                                userManager.isPremium ?
                                                theme.accentColor : Color.black.opacity(0.2)
                                            )
                                            .clipShape(Capsule())
                                    }
                                    
                                    Text("\(HistoryManager.shared.totalLifetimeMinutes) min total")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                            }
                            .padding(24)
                            
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 2)
                                .padding(.horizontal, 20)
                            
                            Button(action: { navigateToAchievements = true }) {
                                SettingsRow(icon: "trophy.fill", title: "Achievements", value: "", theme: theme)
                            }
                        }
                        .background(Color.white.opacity(forceScheme == .dark ? 0.1 : 1))
                        .cornerRadius(30)
                        .padding(.horizontal, 20)
                        
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
                        .background(Color.white.opacity(forceScheme == .dark ? 0.1 : 1))
                        .cornerRadius(30)
                        .padding(.horizontal, 20)
                        
                        HStack {
                            Image(systemName: "moon.fill").foregroundColor(theme.textColor.opacity(0.3))
                            Text("Dark Mode").font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(theme.textColor)
                            Spacer()
                            Toggle("", isOn: $isDarkMode)
                                .toggleStyle(SwitchToggleStyle(tint: theme.accentColor))
                                .labelsHidden()
                        }
                        .padding(.vertical, 14)
                        .padding(.horizontal, 20)
                        .background(Color.white.opacity(forceScheme == .dark ? 0.1 : 1))
                        .cornerRadius(30)
                        .padding(.horizontal, 20)
                        
                        if !userManager.isPremium {
                            Button(action: { navigateToPaywall = true }) {
                                HStack {
                                    Text("Upgrade to Calm Plus")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(theme.textColor)
                                    Spacer()
                                    Text("$0.99")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(theme.textColor.opacity(0.3))
                                }
                                .padding(20)
                                .background(Color.white.opacity(forceScheme == .dark ? 0.1 : 1))
                                .cornerRadius(30)
                                .padding(.horizontal, 20)
                            }
                            .navigationDestination(isPresented: $navigateToPaywall) {
                                PaywallView()
                            }
                        } else {
                            Button(action: { navigateToManageSubscription = true }) {
                                HStack {
                                    Text("Manage Subscription")
                                        .font(.system(size: 16, weight: .medium, design: .rounded))
                                        .foregroundColor(theme.textColor)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(theme.textColor.opacity(0.3))
                                }
                                .padding(20)
                                .background(Color.white.opacity(forceScheme == .dark ? 0.1 : 1))
                                .cornerRadius(30)
                                .padding(.horizontal, 20)
                            }
                            .navigationDestination(isPresented: $navigateToManageSubscription) {
                                ManageSubscriptionView()
                            }
                        }
                    }
                    
                    Spacer(minLength: 0)
                    
                    HStack {
                        Button(action: { dismissAction() }) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 16, weight: .medium))
                                Text("back")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                            }
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .glassEffect(.clear.interactive())
                            .foregroundStyle(theme.textColor)
                        }
                        Spacer()
                        Text("PROFILE").font(.system(size: 16, weight: .medium, design: .rounded)).tracking(2)
                            .padding(.vertical, 12).padding(.horizontal, 18)
                            .glassEffect(.clear.interactive()).foregroundStyle(theme.textColor.opacity(0.7))
                    }
                    .padding(.horizontal, 20).padding(.bottom, 0)
                }
                .safeAreaPadding(.bottom)
            }
            .environment(\.colorScheme, forceScheme)
            .navigationDestination(isPresented: $navigateToAchievements) {
                AchievementsGridView(isDarkMode: isDarkMode)
            }
            .sheet(isPresented: $showSounds) { SelectionSheet(type: .sound, theme: theme).presentationDetents([.fraction(0.7)]).presentationDragIndicator(.visible) }
            .sheet(isPresented: $showThemes) { SelectionSheet(type: .theme, theme: theme).presentationDetents([.fraction(0.7)]).presentationDragIndicator(.visible) }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    let theme: AppTheme
    
    var body: some View {
        HStack {
            Image(systemName: icon).foregroundColor(theme.textColor.opacity(0.3))
            Text(title).font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(theme.textColor)
            Spacer()
            Text(value).font(.system(size: 16, weight: .medium, design: .rounded)).foregroundColor(theme.textColor.opacity(0.3))
            Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundColor(theme.textColor.opacity(0.3))
        }
        .padding(20)
    }
}

struct SelectionSheet: View {
    enum SelectionType { case sound, theme }
    let type: SelectionType
    let theme: AppTheme
    
    @Environment(\.dismiss) var dismiss
    @State private var previewManager = SoundPreviewManager()
    
    var titleText: String {
        type == .sound ? "Select Sound" : "Select Theme"
    }
    
    var body: some View {
        VStack {
            Text(titleText)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.textColor)
                .padding(.top, 25)
            
            ScrollView {
                VStack(spacing: 12) {
                    if type == .sound {
                        SoundListView(theme: theme, dismiss: _dismiss, previewManager: previewManager)
                    } else {
                        ThemeListView(theme: theme, dismiss: _dismiss)
                    }
                }
                .padding(20)
            }
        }
        .onDisappear {
            previewManager.stop(fadeOut: false)
        }
    }
}

struct SoundListView: View {
    let theme: AppTheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    var previewManager: SoundPreviewManager
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(UserManager.shared.sounds.enumerated()), id: \.element.id) { index, sound in
                
                let isLocked = !UserManager.shared.isPremium && index >= 2
                let isSelected = UserManager.shared.selectedSoundID == sound.id
                let isPlaying = previewManager.playingSoundID == sound.id
                
                ZStack(alignment: .leading) {
                    
                    RoundedRectangle(cornerRadius: 30)
                        .fill(.white)
                        .opacity(colorScheme == .dark ? 0.1 : 1.0)
                    
                    GeometryReader { geo in
                        if isPlaying {
                            Rectangle()
                                .fill(theme.accentColor.opacity(0.15))
                                .frame(width: geo.size.width * previewManager.progress)
                                .animation(.linear(duration: 0.05), value: previewManager.progress)
                        }
                    }
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            previewManager.togglePreview(for: sound)
                        }) {
                            ZStack {
                                Circle()
                                    .fill(theme.accentColor.opacity(0.2))
                                
                                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(theme.accentColor)
                                    .offset(x: isPlaying ? 0 : 2)
                            }
                            .frame(width: 44, height: 44)
                        }
                        .disabled(isLocked)
                        Text(sound.name)
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(isLocked ? .gray : theme.textColor)
                        
                        Spacer()
                        
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .foregroundColor(theme.textColor.opacity(0.3))
                                .padding(.trailing, 20)
                        } else if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundColor(theme.accentColor)
                                .padding(.trailing, 20)
                        }
                    }
                    .padding(.leading, 10)
                    .padding(.vertical, 8)
                    
                }
                .frame(height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(isSelected ? theme.accentColor : theme.textColor.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    if !isLocked {
                        UserManager.shared.selectedSoundID = sound.id
                        dismiss()
                    }
                }
                .opacity(isLocked ? 0.6 : 1.0)
            }
        }
    }
}

struct ThemeListView: View {
    let theme: AppTheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ForEach(Array(UserManager.shared.themes.enumerated()), id: \.element.id) { index, itemTheme in
            SelectionRow(
                title: itemTheme.name,
                isSelected: UserManager.shared.selectedThemeID == itemTheme.id,
                isLocked: !UserManager.shared.isPremium && index >= 2,
                preview: itemTheme.gradient,
                theme: theme
            ) {
                if !UserManager.shared.isPremium && index >= 2 { return }
                UserManager.shared.selectedThemeID = itemTheme.id
                dismiss()
            }
        }
    }
}

struct SelectionRow: View {
    @Environment(\.colorScheme) var colorScheme
    
    let title: String
    let isSelected: Bool
    let isLocked: Bool
    var preview: LinearGradient?
    
    let theme: AppTheme
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                if let gradient = preview {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(gradient)
                        .frame(width: 40, height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.2), lineWidth: 1))
                } else {
                    ZStack {
                        Circle().fill(theme.accentColor.opacity(0.1))
                        Image(systemName: "play.fill").font(.system(size: 12)).foregroundColor(theme.accentColor)
                    }
                    .frame(width: 40, height: 40)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(isLocked ? .gray : theme.textColor)
                
                Spacer()
                
                if isLocked {
                    Image(systemName: "lock.fill").foregroundColor(theme.textColor.opacity(0.3))
                        .padding(.trailing, 8)
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(theme.accentColor)
                        .padding(.trailing, 8)
                }
            }
            .padding(12)
            .background(
                Color.white.opacity(
                    colorScheme == .dark ? (isSelected ? 0.1 : 0.05) : 1.0
                )
            )
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .disabled(isLocked)
    }
}

struct MedalsListView: View {
    let theme: AppTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Achievements")
                    .font(.title2.bold())
                    .foregroundColor(theme.textColor)
                    .padding(.top, 20)
                
                ForEach(UserManager.shared.medals) { medal in
                    HStack(spacing: 15) {
                        Image(systemName: medal.icon)
                            .font(.system(size: 30))
                            .foregroundColor(theme.accentColor)
                            .frame(width: 60, height: 60)
                            .background(theme.accentColor.opacity(0.1))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(medal.name)
                                .font(.headline)
                                .foregroundColor(theme.textColor)
                            Text(medal.description)
                                .font(.caption)
                                .foregroundColor(theme.textColor.opacity(0.5))
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 1.0))
                    .cornerRadius(30)
                }
            }
            .padding(20)
        }
    }
}

@MainActor
extension View {
    func snapshot() -> UIImage? {
        let renderer = ImageRenderer(content: self)
        renderer.scale = UITraitCollection.current.displayScale
        return renderer.uiImage
    }
}
