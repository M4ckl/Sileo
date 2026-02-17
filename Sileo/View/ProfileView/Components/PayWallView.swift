import SwiftUI
import StoreKit

struct CalmPlusIcon: View {
    var theme: AppTheme
    @State private var isBreathing = false
    @State private var isFloating = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [theme.accentColor, theme.accentColor.opacity(0.6), .orange],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 120, height: 120)
                .shadow(color: theme.accentColor.opacity(0.5), radius: 20, x: 0, y: 10)
            
            Image("CalmPlusImage")
                .resizable()
                .renderingMode(.original)
                .scaledToFit()
                .frame(width: 128, height: 128)
                .opacity(isBreathing ? 1.0 : 0.7)
                .shadow(color: .white.opacity(isBreathing ? 0.8 : 0.2), radius: isBreathing ? 15 : 5)
        }
        .offset(y: isFloating ? -5 : 5)
        .rotation3DEffect(
            .degrees(isFloating ? 2 : -2),
            axis: (x: 1, y: 0, z: 0)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isBreathing.toggle()
            }
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                isFloating.toggle()
            }
        }
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) var dismiss
    @State private var storeManager = StoreManager.shared
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
                    Text("CALM PLUS")
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
                            
                            Text("It’s a small contribution to your own calm.")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundStyle(theme.textColor)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            VStack(spacing: 10) {
                                Text("No pressure. No goals.")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundStyle(theme.accentColor.opacity(0.6))
                                
                                Text("Just more space to breathe.")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                                    .foregroundStyle(.white)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(theme.accentColor.opacity(0.15))
                                    .clipShape(Capsule())
                            }
                            .multilineTextAlignment(.center)
                            .padding(.top, 5)
                        }
                        .padding(.bottom, 30)
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("WHAT'S INCLUDED")
                                .font(.system(size: 12, weight: .bold, design: .rounded))
                                .foregroundColor(theme.textColor.opacity(0.5))
                                .padding(.leading, 10)
                                .padding(.bottom, 5)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                FeatureRow(icon: "infinity", title: "Unlimited pauses", description: "Focus as much as you need without daily limits.", theme: theme)
                                Divider().padding(.leading, 10).opacity(0.7)
                                FeatureRow(icon: "paintpalette.fill", title: "4 additional themes", description: "Personalize your experience with exclusive colors.", theme: theme)
                                Divider().padding(.leading, 10).opacity(0.7)
                                FeatureRow(icon: "speaker.wave.2.fill", title: "4 additional sounds", description: "Unlock premium ambient sounds for deep focus.", theme: theme)
                            }
                            .padding(.vertical, 20)
                            .padding(.horizontal, 20)
                            .background(Color.white.opacity(colorScheme == .dark ? 0.1 : 0.8))
                            .cornerRadius(24)
                            .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 20)
                        .opacity(textOpacity)
                        .offset(y: textOffset)
                        
                        Spacer(minLength: 200)
                    }
                }
            }
            
            VStack {
                Spacer()
                LinearGradient(
                    colors: [
                        theme.accentColor.opacity(0.5),
                        theme.accentColor.opacity(0.0)
                    ],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 250)
            }
            .ignoresSafeArea()
            .opacity(textOpacity)
            
            VStack {
                Spacer()
                
                VStack(spacing: 12) {
                    if let product = storeManager.products.first {
                        Button(action: {
                            Task {
                                await storeManager.purchase(product)
                                if UserManager.shared.isPremium { dismiss() }
                            }
                        }) {
                            Text("Purchase for \(product.displayPrice) / month")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(theme.accentColor)
                                .cornerRadius(30)
                                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                        }
                    } else {
                        ProgressView().tint(theme.textColor).padding()
                    }
                    
                    Button("Restore Purchases") {
                        Task { await storeManager.restorePurchases() }
                    }
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 10)
            }
            .opacity(textOpacity)
            .offset(y: textOffset)
        }
        .navigationBarHidden(true)
        .preferredColorScheme(isDarkMode ? .dark : .light)
        .task {
            await storeManager.loadProducts()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.2)) {
                textOpacity = 1
                textOffset = 0
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    let theme: AppTheme
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(theme.accentColor)
                .frame(width: 24)
                .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(theme.textColor)
                
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundColor(theme.textColor.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
        .padding(.vertical, 12)
    }
}
