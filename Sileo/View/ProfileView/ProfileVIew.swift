import SwiftUI
import PhotosUI

// ГЛАВНЫЙ ЭКРАН ПРОФИЛЯ
struct ProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(UserManager.self) var userManager
    
    // Настройка темы (читаем из UserDefaults)
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    var body: some View {
        ZStack {
            InternalProfileContent(
                isDarkMode: $isDarkMode, // Передаем Binding
                dismissAction: { dismiss() },
                forceScheme: .light
            )
            .environment(userManager) // Обязательно передаем менеджер
            .opacity(isDarkMode ? 0 : 1)
            
            InternalProfileContent(
                isDarkMode: $isDarkMode,
                dismissAction: { dismiss() },
                forceScheme: .dark
            )
            .environment(userManager)
            .opacity(isDarkMode ? 1 : 0) // Если включена темная, показываем
        }
        // ✅ ГЛАВНАЯ МАГИЯ: Плавная анимация прозрачности (Cross Dissolve)
        .animation(.easeInOut(duration: 0.5), value: isDarkMode)
        .navigationBarHidden(true)
    }
}

// ВНУТРЕННИЙ КОНТЕНТ ПРОФИЛЯ
struct InternalProfileContent: View {
    @Binding var isDarkMode: Bool
    var dismissAction: () -> Void
    var forceScheme: ColorScheme
    
    @Environment(UserManager.self) var userManager
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    // Навигация
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
                        
                        // БЛОК 1: ПРОФИЛЬ + АЧИВКИ (Вместе)
                        VStack(spacing: 0) {
                            
                            // 1. ЧАСТЬ ПРОФИЛЯ (Инфо)
                            HStack(spacing: 20) {
                                
                                // ✅ СТАТИЧНАЯ АВАТАРКА
                                ZStack {
                                    Circle()
                                        .fill(theme.accentColor.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                    
                                    Image(systemName: "person.circle.fill") // Фирменная иконка
                                        .font(.system(size: 40))
                                        .foregroundColor(theme.accentColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(alignment: .center, spacing: 8) {
                                        // ✅ Просто текст уровня (без .title)
                                        Text(userManager.getUserLevel())
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                            .foregroundColor(theme.textColor)
                                        
                                        // Бейджик подписки
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
                            
                            // 2. РАЗДЕЛИТЕЛЬ
                            Capsule()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 2)
                                .padding(.horizontal, 20)
                            
                            // 3. КНОПКА АЧИВОК
                            Button(action: { navigateToAchievements = true }) {
                                SettingsRow(icon: "trophy.fill", title: "Achievements", value: "", theme: theme)
                            }
                        }
                        // ОБЩИЙ ФОН БЛОКА
                        .background(Color.white.opacity(forceScheme == .dark ? 0.1 : 1))
                        .cornerRadius(30)
                        .padding(.horizontal, 20)
                        
                        // БЛОК 3: НАСТРОЙКИ (ЗВУК И ТЕМА)
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
                        
                        // БЛОК 4: DARK MODE
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
                        
                        // БЛОК 5: ПОДПИСКА
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
                    
                    // НИЖНЯЯ ПАНЕЛЬ
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
            // Навигация для ачивок (привязана к стеку)
            .navigationDestination(isPresented: $navigateToAchievements) {
                AchievementsGridView(isDarkMode: isDarkMode) // ✅ ПЕРЕДАЕМ НАСТРОЙКУ
            }
            .sheet(isPresented: $showSounds) { SelectionSheet(type: .sound, theme: theme).presentationDetents([.fraction(0.7)]).presentationDragIndicator(.visible) }
            .sheet(isPresented: $showThemes) { SelectionSheet(type: .theme, theme: theme).presentationDetents([.fraction(0.7)]).presentationDragIndicator(.visible) }
        }
    }
}

// Вспомогательная строка настроек
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

// --- ОБНОВЛЛЕННЫЙ ЛИСТ ВЫБОРА (Sound / Theme) ---
struct SelectionSheet: View {
    enum SelectionType { case sound, theme }
    let type: SelectionType
    let theme: AppTheme
    @Environment(\.dismiss) var dismiss
    
    var titleText: String {
        type == .sound ? "Select Sound" : "Select Theme"
    }
    
    var body: some View {
        VStack {
            Text(titleText)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .padding(.top, 25)
            
            ScrollView {
                VStack(spacing: 12) {
                    // Используем отдельные View, чтобы упростить структуру для компилятора
                    if type == .sound {
                        SoundListView(theme: theme, dismiss: _dismiss)
                    } else {
                        ThemeListView(theme: theme, dismiss: _dismiss)
                    }
                }
                .padding(20)
            }
        }
    }
}

// --- ОТДЕЛЬНЫЙ СПИСОК ЗВУКОВ ---
struct SoundListView: View {
    let theme: AppTheme
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        // ✅ Обернули в VStack, чтобы убрать неоднозначность для компилятора
        VStack(spacing: 12) {
            ForEach(Array(UserManager.shared.sounds.enumerated()), id: \.element.id) { index, sound in
                SelectionRow(
                    title: sound.name,
                    isSelected: UserManager.shared.selectedSoundID == sound.id,
                    isLocked: !UserManager.shared.isPremium && index >= 2,
                    preview: nil,
                    theme: theme // Теперь это точно не конфликтует с action
                ) {
                    // Action (замыкание) теперь корректно распознается как последний аргумент
                    if !UserManager.shared.isPremium && index >= 2 { return }
                    UserManager.shared.selectedSoundID = sound.id
                    dismiss()
                }
            }
        }
    }
}

// --- ОТДЕЛЬНЫЙ СПИСОК ТЕМ ---
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

// Ряд выбора с превью
struct SelectionRow: View {
    @Environment(\.colorScheme) var colorScheme
    
    // ПОРЯДОК ПЕРЕМЕННЫХ ВАЖЕН:
    let title: String
    let isSelected: Bool
    let isLocked: Bool
    var preview: LinearGradient?
    
    // 1. Сначала тема
    let theme: AppTheme
    
    // 2. Action ОБЯЗАТЕЛЬНО должен быть последним, чтобы работали { }
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                
                // Превью (Градиент для темы или иконка звука)
                if let gradient = preview {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(gradient)
                        .frame(width: 40, height: 40)
                        .overlay(RoundedRectangle(cornerRadius: 30).stroke(Color.white.opacity(0.2), lineWidth: 1))
                } else {
                    // Иконка для звука
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
            )// Подсветка активного
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(isSelected ? theme.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .disabled(isLocked)
    }
}

// --- СПИСОК МЕДАЛЕЙ ---
struct MedalsListView: View {
    // 1. Обязательно принимаем тему
    let theme: AppTheme
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("Achievements")
                    .font(.title2.bold())
                    .foregroundColor(theme.textColor) // Используем тему
                    .padding(.top, 20)
                
                // Используем массив из UserManager
                ForEach(UserManager.shared.medals) { medal in
                    HStack(spacing: 15) {
                        Image(systemName: medal.icon)
                            .font(.system(size: 30))
                            .foregroundColor(theme.accentColor) // Используем тему
                            .frame(width: 60, height: 60)
                            .background(theme.accentColor.opacity(0.1)) // Используем тему
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text(medal.name)
                                .font(.headline)
                                .foregroundColor(theme.textColor) // Используем тему
                            Text(medal.description)
                                .font(.caption)
                                .foregroundColor(theme.textColor.opacity(0.5)) // Используем тему
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
        // Avoid deprecated UIScreen.main; use trait-based scale
        renderer.scale = UITraitCollection.current.displayScale
        return renderer.uiImage
    }
}
