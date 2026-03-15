import SwiftUI

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
