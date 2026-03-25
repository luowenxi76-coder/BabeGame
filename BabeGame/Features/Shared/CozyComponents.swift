import SwiftUI

enum CozyPalette {
    static let ink = Color(red: 0.21, green: 0.18, blue: 0.18)
    static let cream = Color(red: 0.96, green: 0.90, blue: 0.76)
    static let ginger = Color(red: 0.92, green: 0.60, blue: 0.31)
    static let cocoa = Color(red: 0.55, green: 0.39, blue: 0.28)
    static let charcoal = Color(red: 0.33, green: 0.34, blue: 0.39)
    static let snow = Color(red: 0.98, green: 0.98, blue: 0.97)
    static let calico = Color(red: 0.86, green: 0.62, blue: 0.42)
    static let jade = Color(red: 0.30, green: 0.65, blue: 0.45)
    static let amber = Color(red: 0.85, green: 0.60, blue: 0.18)
    static let sky = Color(red: 0.43, green: 0.71, blue: 0.92)
    static let coffee = Color(red: 0.40, green: 0.28, blue: 0.20)
    static let blush = Color(red: 0.93, green: 0.67, blue: 0.64)
    static let paper = Color(red: 0.99, green: 0.97, blue: 0.94)
    static let butter = Color(red: 0.99, green: 0.91, blue: 0.65)
    static let mint = Color(red: 0.77, green: 0.91, blue: 0.84)
    static let peach = Color(red: 0.98, green: 0.77, blue: 0.64)
    static let berry = Color(red: 0.82, green: 0.66, blue: 0.78)
    static let pearl = Color(red: 0.89, green: 0.88, blue: 0.94)
    static let indigo = Color(red: 0.49, green: 0.51, blue: 0.72)
    static let gold = Color(red: 0.90, green: 0.75, blue: 0.37)

    static func accent(for key: String) -> Color {
        switch key {
        case "mint": mint
        case "peach": peach
        case "berry": berry
        case "sky": sky
        case "butter": butter
        case "pearl": pearl
        case "indigo": indigo
        case "gold": gold
        default: peach
        }
    }

    static func wallpaperBackground(for wallpaper: WallpaperStyle) -> LinearGradient {
        switch wallpaper {
        case .sunny:
            LinearGradient(colors: [butter.opacity(0.75), paper, peach.opacity(0.58)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .mint:
            LinearGradient(colors: [mint.opacity(0.78), paper, sky.opacity(0.38)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .berry:
            LinearGradient(colors: [berry.opacity(0.76), paper, peach.opacity(0.42)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct CozyCard<Content: View>: View {
    let accent: Color
    let content: Content

    init(accent: Color = CozyPalette.peach, @ViewBuilder content: () -> Content) {
        self.accent = accent
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            content
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(CozyPalette.paper.opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(accent.opacity(0.45), lineWidth: 1.2)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 18, y: 10)
        )
    }
}

struct CozySectionTitle: View {
    let eyebrow: String?
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let eyebrow {
                Text(eyebrow.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.3)
                    .foregroundStyle(CozyPalette.ink.opacity(0.42))
            }

            Text(title)
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundStyle(CozyPalette.ink)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(CozyPalette.ink.opacity(0.68))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct CurrencyBadge: View {
    let coins: Int

    var body: some View {
        Label("\(coins) 金币", systemImage: "sparkles")
            .font(.subheadline.weight(.bold))
            .foregroundStyle(CozyPalette.ink)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                Capsule()
                    .fill(CozyPalette.butter.opacity(0.82))
                    .overlay(Capsule().stroke(CozyPalette.gold.opacity(0.55), lineWidth: 1))
            )
    }
}

struct TagPill: View {
    let label: String
    var accent: Color = CozyPalette.mint

    var body: some View {
        Text(label)
            .font(.caption.weight(.semibold))
            .foregroundStyle(CozyPalette.ink)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(Capsule().fill(accent.opacity(0.55)))
    }
}

struct CozyBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                CozyPalette.paper,
                CozyPalette.butter.opacity(0.54),
                CozyPalette.peach.opacity(0.48)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct EmptyStateCard: View {
    let title: String
    let subtitle: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        CozyCard(accent: CozyPalette.mint) {
            CozySectionTitle(eyebrow: "First Cat", title: title, subtitle: subtitle)

            Button(buttonTitle, action: action)
                .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.mint))
        }
    }
}

struct CozyPrimaryButtonStyle: ButtonStyle {
    var accent: Color = CozyPalette.peach

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(CozyPalette.ink)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(accent.opacity(configuration.isPressed ? 0.65 : 0.95))
            )
            .scaleEffect(configuration.isPressed ? 0.985 : 1)
            .animation(.easeOut(duration: 0.16), value: configuration.isPressed)
    }
}

struct LabelValueRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(CozyPalette.ink.opacity(0.6))
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(CozyPalette.ink)
        }
        .font(.subheadline)
    }
}

extension TimeInterval {
    var cooldownText: String {
        let totalSeconds = max(0, Int(self))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

extension Date {
    var cozyDayText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "M月d日"
        return formatter.string(from: self)
    }
}
