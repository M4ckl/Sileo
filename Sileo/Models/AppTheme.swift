import Observation
import SwiftUI

struct AppTheme: Identifiable, Equatable {
    let id: String
    let name: String
    
    let accentColorName: String
    let textColorName: String
    let secondTextColorName: String
    
    let backColor1: String
    let backColor2: String
    let backColor3: String
    let backColor4: String
    let backImage: String
    
    let gradient: LinearGradient
    
    var accentColor: Color { Color(accentColorName) }
    var textColor: Color { Color(textColorName) }
    var secondTextColor: Color { Color(secondTextColorName) }
    
    static func == (lhs: AppTheme, rhs: AppTheme) -> Bool {
        return lhs.id == rhs.id
    }
}
