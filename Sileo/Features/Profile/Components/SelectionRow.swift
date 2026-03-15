import  SwiftUI

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
