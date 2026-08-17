import SwiftUI


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
                
                ForEach(Medal.all) { medal in
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

