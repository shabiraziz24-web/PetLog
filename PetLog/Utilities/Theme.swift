import SwiftUI

enum Theme {
    static let primaryColor = Color(hex: "FF6B35")
    static let secondaryColor = Color(hex: "2EC4B6")
    static let backgroundWarm = Color(hex: "FFF8F0")

    static let cardCornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 10
    static let cardShadowRadius: CGFloat = 4
    static let cardShadowY: CGFloat = 2

    static let horizontalPadding: CGFloat = 16
    static let verticalSpacing: CGFloat = 12

    static func cardStyle() -> some ViewModifier {
        CardModifier()
    }
}

struct CardModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: Theme.cardCornerRadius)
                    .fill(colorScheme == .dark ? Color(.systemGray6) : .white)
                    .shadow(color: .black.opacity(0.08), radius: Theme.cardShadowRadius, y: Theme.cardShadowY)
            )
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardModifier())
    }
}
