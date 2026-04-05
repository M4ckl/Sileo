import SwiftUI

struct SelectionSheet: View {
    enum SelectionType { case sound, theme }
    let type: SelectionType
    let theme: AppTheme
    
    @Environment(\.dismiss) var dismiss
    @State private var previewManager = SoundPreviewManager()
    
    var titleText: String { type == .sound ? "Select Sound" : "Select Theme" }
    
    var body: some View {
        VStack {
            Text(titleText)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(theme.textColor)
                .padding(.top, 25)
            
            ScrollView {
                VStack(spacing: 12) {
                    if type == .sound {
                        SoundListView(theme: theme, previewManager: previewManager)
                    } else {
                        ThemeListView(theme: theme)
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
    @Bindable var previewManager: SoundPreviewManager
    
    var body: some View {
        ForEach(Array(UserManager.shared.sounds.enumerated()), id: \.element.id) { index, sound in
            let isLocked = !UserManager.shared.isPremium && index >= 3
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
                    Button(action: { previewManager.togglePreview(for: sound) }) {
                        ZStack {
                            Circle().fill(theme.accentColor.opacity(0.2))
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

struct ThemeListView: View {
    let theme: AppTheme
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ForEach(Array(UserManager.shared.themes.enumerated()), id: \.element.id) { index, itemTheme in
            let isSelected = UserManager.shared.selectedThemeID == itemTheme.id
            let isLocked = !UserManager.shared.isPremium && index >= 2
            
            Button(action: {
                if !isLocked {
                    UserManager.shared.selectedThemeID = itemTheme.id
                    dismiss()
                }
            }) {
                HStack(spacing: 15) {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(itemTheme.gradient)
                        .frame(width: 40, height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.2), lineWidth: 1))
                    
                    Text(itemTheme.name)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(isLocked ? .gray : theme.textColor)
                    
                    Spacer()
                    
                    if isLocked {
                        Image(systemName: "lock.fill").foregroundColor(theme.textColor.opacity(0.3)).padding(.trailing, 8)
                    } else if isSelected {
                        Image(systemName: "checkmark.circle.fill").font(.title3).foregroundColor(theme.accentColor).padding(.trailing, 8)
                    }
                }
                .padding(12)
                .background(Color.white.opacity(colorScheme == .dark ? (isSelected ? 0.1 : 0.05) : 1.0))
                .cornerRadius(30)
                .overlay(RoundedRectangle(cornerRadius: 30).stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2))
            }
            .disabled(isLocked)
        }
    }
}
