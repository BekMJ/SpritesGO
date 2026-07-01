import SwiftUI

enum Theme {
    static let pink = Color(hex: "#FFD0E1")
    static let sky = Color(hex: "#CDEBFF")
    static let mint = Color(hex: "#D4F3DA")
    static let lemon = Color(hex: "#FFF3B8")
    static let lavender = Color(hex: "#E4D9FF")
    static let peach = Color(hex: "#FFDCC8")
    static let coral = Color(hex: "#F58FA1")
    static let ink = Color(hex: "#574C68")
    static let cream = Color(hex: "#FFFBF7")

    static let roundedFont = Font.system(.body, design: .rounded)
    static let titleFont = Font.system(size: 46, weight: .black, design: .rounded)

    static var background: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "#FFF1F7"), Color(hex: "#EEF7FF"), Color(hex: "#F2F0FF"), Color(hex: "#F3FFF4")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var value: UInt64 = 0
        scanner.scanHexInt64(&value)
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        self.init(red: red, green: green, blue: blue)
    }
}

struct PastelButtonStyle: ButtonStyle {
    var color: Color = Theme.pink

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .rounded).weight(.bold))
            .foregroundStyle(Theme.ink)
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(color)
                    .shadow(color: color.opacity(configuration.isPressed ? 0.15 : 0.35), radius: configuration.isPressed ? 3 : 10, y: 6)
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 18, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 46, height: 46)
                .background(Circle().fill(Color.red.opacity(0.82)))
        }
        .accessibilityLabel("Close")
    }
}
