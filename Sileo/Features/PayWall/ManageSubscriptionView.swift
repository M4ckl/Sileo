import SwiftUI
import StoreKit

struct ManageSubscriptionView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Environment(UserManager.self) var userManager
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @State private var textOpacity: Double = 0
    @State private var textOffset: CGFloat = 20
    
    var theme: AppTheme { userManager.getCurrentTheme() }
    
    var body: some View {
        ZStack {
            BackgroundOnlyColorsView()
                .ignoresSafeArea()
            
            ParticleBackgroundView(color: .white)
                .ignoresSafeArea()
                .mask(
                    LinearGradient(
                        gradient: Gradient(colors: [.black, .black, .clear]),
                        startPoint: .top,
                        endPoint: .center
                    )
                )
            
            VStack(spacing: 0) {
                // MARK: - Header
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 24))
                            .foregroundColor(theme.textColor)
                            .frame(width: 44, height: 44)
                            .glassEffect(.clear.interactive())
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("MY PLAN")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(theme.textColor)
                        .textCase(.uppercase)
                        .tracking(1)
                    
                    Spacer()

                    Color.clear.frame(width: 44, height: 44)
                }
                .padding(.horizontal)
                .padding(.top)
                .zIndex(1)
                
                // MARK: - Content
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        SpinningModelView(modelName: "lotus.usdz", accentColor: Color(theme.accentColor))
                            .frame(width: 120, height: 120)
                            .shadow(color: theme.accentColor.opacity(0.3), radius: 8, x: 0, y: 8)
                            .padding(.top, 20)
                        
                        VStack(spacing: 12) {
                            Text("You have full access.")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.textColor)
                                .multilineTextAlignment(.center)
                            
                            Text("Calm Plus Active")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundColor(theme.accentColor)
                                .textCase(.uppercase)
                                .tracking(0.5)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(theme.accentColor.opacity(colorScheme == .dark ? 0.15 : 0.08))
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.bottom, 40)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("CURRENTLY ACTIVE")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundColor(theme.textColor.opacity(0.5))
                            .padding(.leading, 10)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            ActiveFeatureRow(icon: "infinity", title: "Unlimited pauses", theme: theme)
                            Divider().padding(.leading, 50).opacity(0.5)
                            ActiveFeatureRow(icon: "paintpalette.fill", title: "All themes unlocked", theme: theme)
                            Divider().padding(.leading, 50).opacity(0.5)
                            ActiveFeatureRow(icon: "speaker.wave.2.fill", title: "All sounds unlocked", theme: theme)
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal, 15)
                        .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.8))
                        .cornerRadius(24)
                        
                        Text("Thank you for supporting Sileo.")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(theme.textColor.opacity(0.6))
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 10)
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // MARK: - Footer Buttons
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
                                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
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
                        .padding(.bottom, 10)
                        #endif
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .opacity(textOpacity)
                .offset(y: textOffset)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                textOpacity = 1
                textOffset = 0
            }
        }
    }
}
