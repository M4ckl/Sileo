import SwiftUI
import StoreKit

struct ManageSubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(UserManager.self) var userManager
    @AppStorage("isDarkMode") private var isDarkMode = false

    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    
    var theme: AppTheme {
        userManager.getCurrentTheme()
    }
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 24))
                        }
                        .foregroundColor(theme.textColor)
                        .padding(.vertical ,8)
                        .padding(.horizontal , 12)
                        .clipShape(Capsule())
                        .glassEffect(.clear.interactive())
                    }
                    Spacer()
                    Text("MY PLAN")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textColor)
                        .textCase(.uppercase)
                        .tracking(1)
                    Spacer()
                    Image(systemName: "chevron.left").opacity(0).padding()
                }
                .padding(.horizontal)
                .padding(.top)
                .zIndex(1)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        VStack(spacing: 20) {
                            CalmPlusIcon(theme: theme)
                                .padding(.top, 10)
                            
                            VStack(spacing: 12) {
                                Text("You have full access.")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundStyle(theme.textColor)
                                    .multilineTextAlignment(.center)

                                HStack(spacing: 6) {
                                    Text("Calm Plus Active")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(theme.accentColor)
                                        .textCase(.uppercase)
                                        .tracking(0.5)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(theme.accentColor.opacity(colorScheme == .dark ? 0.15 : 0.08))
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.bottom, 30)
                        .opacity(textOpacity)
                        .offset(y: textOffset)

                        VStack(alignment: .leading, spacing: 10) {
                            Text("CURRENTLY ACTIVE")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(theme.textColor.opacity(0.5))
                                .padding(.leading, 10)
                                .padding(.bottom, 5)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                ActiveFeatureRow(icon: "infinity", title: "Unlimited pauses", theme: theme)
                                Divider().padding(.leading, 50).opacity(0.5)
                                ActiveFeatureRow(icon: "paintpalette.fill", title: "All themes unlocked", theme: theme)
                                Divider().padding(.leading, 50).opacity(0.5)
                                ActiveFeatureRow(icon: "speaker.wave.2.fill", title: "All sounds unlocked", theme: theme)
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                            .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.8))
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)

                            Text("Thank you for supporting Sileo.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(theme.textColor.opacity(0.6))
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 20)
                        }
                        .padding(.horizontal, 20)
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                        
                        Spacer(minLength: 120)
                    }
                }
            }

            VStack {
                Spacer()
                
                VStack(spacing: 12) {
                    Button(action: {
                        if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text("Manage in Apple Settings")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(theme.accentColor)
                            .cornerRadius(30)
                            .shadow(color: Color.black.opacity(0.3), radius: 12, x: 0, y: 6)
                    }

                    #if DEBUG
                    Button(action: {
                        UserManager.shared.resetSubscription()
                        dismiss()
                    }) {
                        Text("Cancel Subscription (Test Mode)")
                            .font(.system(size: 12, weight: .medium, design: .rounded))
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .padding(.bottom, 5)
                    #endif
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
            .opacity(textOpacity)
            .offset(y: textOffset)
        }
        .navigationBarHidden(true)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                textOpacity = 1
                textOffset = 0
            }
        }
    }
}

struct ActiveFeatureRow: View {
    let icon: String
    let title: String
    let theme: AppTheme
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(theme.accentColor)
                .frame(width: 24)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(theme.textColor)
            
            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(theme.accentColor)
        }
        .padding(.vertical, 12)
    }
}
