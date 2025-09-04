import SwiftUI

enum FontName: String {
    case customBold = "KodeMono-Bold"
    case customSemiBold = "KodeMono-SemiBold"
    case customRegular = "KodeMono-Regular"
    case customMedium = "KodeMono-Medium"
    
    func size(_ size: CGFloat) -> Font {
        return .custom(self.rawValue, size: size)
    }
}


extension Font {
    static func customFont(_ style: FontName, size: CGFloat) -> Font {
        return style.size(size)
    }
}

