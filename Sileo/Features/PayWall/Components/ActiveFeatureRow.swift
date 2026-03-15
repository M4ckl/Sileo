import SwiftUI

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
