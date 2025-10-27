import SwiftUI

extension Color {
    // Your custom static colors - ENSURE THESE HEX VALUES ARE CORRECT FOR YOUR DESIGN
    static let zetaPrimaryPurple = Color(hex: "7359BF")! // Example from CharacterQuestionView buttons
    static let zetaSoftOrange = Color(hex: "FFB74D")!   // Example from ParentZone button
    static let zetaBackgroundGradientStart = Color(hex: "FFF0C1")!
    static let zetaBackgroundGradientEnd = Color(hex: "FFC9D5")!
    static let zetaTextColor = Color.black.opacity(0.75)
    static let zetaButtonSelectedBorder = Color.zetaPrimaryPurple

    // Examples of other colors you might have from WelcomeView for text/buttons
    // Ensure these are the definitive ones or choose a single source of truth for colors
    static let welcomeViewTextPrimary = Color(hex: "3D7C8A")! // Welcome text, Parent Zone text
    static let welcomeViewButtonPurpleDark = Color(hex: "9C27B0")! // Main CTA button
    static let welcomeViewButtonOrangePrimary = Color(hex: "FF9800")! // ParentZone CTA button text


    // Your hex initializer
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
