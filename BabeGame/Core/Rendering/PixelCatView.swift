import SwiftUI

struct PixelCatView: View {
    let appearance: CatAppearance
    let outfit: OutfitDefinition?
    let accessory: AccessoryDefinition?
    var scale: CGFloat = 12

    var body: some View {
        let pixels = PixelCatRenderer.pixels(for: appearance, outfit: outfit, accessory: accessory)

        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.black.opacity(0.06))
                .frame(width: scale * 14, height: scale * 2.2)
                .offset(y: scale * 5.5)

            ZStack(alignment: .topLeading) {
                ForEach(Array(pixels.enumerated()), id: \.offset) { _, pixel in
                    Rectangle()
                        .fill(pixel.color)
                        .frame(width: scale, height: scale)
                        .offset(x: CGFloat(pixel.x) * scale, y: CGFloat(pixel.y) * scale)
                }
            }
            .frame(width: scale * 16, height: scale * 16, alignment: .topLeading)
        }
        .frame(width: scale * 16, height: scale * 18)
        .accessibilityLabel("像素猫咪预览")
    }
}

private struct PixelCell {
    let x: Int
    let y: Int
    let color: Color
}

private enum PixelCatRenderer {
    static func pixels(for appearance: CatAppearance, outfit: OutfitDefinition?, accessory: AccessoryDefinition?) -> [PixelCell] {
        let primary = appearance.primaryFur.color
        let secondary = appearance.secondaryFur.color
        let outline = CozyPalette.ink
        let eyes = appearance.eyeColor.color
        let outfitColor = accentColor(for: outfit?.accentKey)
        let accessoryColor = accentColor(for: accessory?.accentKey)

        var cells: [PixelCell] = []

        func paint(_ x: Int, _ y: Int, _ color: Color) {
            cells.append(PixelCell(x: x, y: y, color: color))
        }

        for x in 4...11 {
            for y in 4...12 {
                paint(x, y, primary)
            }
        }

        for x in 5...10 {
            for y in 2...5 {
                paint(x, y, primary)
            }
        }

        let earHeight: ClosedRange<Int> = switch appearance.earShape {
        case .round: 1...2
        case .pointy: 0...2
        case .fluffy: 0...3
        }
        for y in earHeight {
            paint(4, y + 1, outline)
            paint(5, y, primary)
            paint(10, y, primary)
            paint(11, y + 1, outline)
        }

        for x in 3...12 {
            paint(x, 3, outline)
        }
        for y in 4...12 {
            paint(3, y, outline)
            paint(12, y, outline)
        }
        for x in 4...11 {
            paint(x, 13, outline)
        }

        paint(6, 5, eyes)
        paint(9, 5, eyes)
        paint(6, 6, outline)
        paint(9, 6, outline)
        paint(7, 7, CozyPalette.blush)
        paint(8, 7, CozyPalette.blush)

        switch appearance.pattern {
        case .solid:
            break
        case .striped:
            for y in [4, 6, 8] {
                paint(5, y, secondary)
                paint(10, y, secondary)
            }
            paint(7, 4, secondary)
            paint(8, 4, secondary)
        case .patches:
            for x in 5...7 {
                paint(x, 4, secondary)
            }
            for x in 8...10 {
                paint(x, 9, secondary)
            }
        case .socks:
            for x in 4...5 {
                paint(x, 11, CozyPalette.cream)
                paint(x, 12, CozyPalette.cream)
            }
            for x in 10...11 {
                paint(x, 11, CozyPalette.cream)
                paint(x, 12, CozyPalette.cream)
            }
        case .cloudy:
            for x in 6...9 {
                paint(x, 9, secondary)
                paint(x, 10, secondary.opacity(0.9))
            }
        }

        switch appearance.facePattern {
        case .plain:
            break
        case .mask:
            for x in 5...10 {
                paint(x, 4, secondary)
                paint(x, 5, secondary.opacity(0.95))
            }
        case .blaze:
            for y in 3...7 {
                paint(7, y, CozyPalette.cream)
                paint(8, y, CozyPalette.cream)
            }
        case .noseDot:
            paint(7, 6, secondary)
            paint(8, 6, secondary)
        }

        let bodyInset: Int = switch appearance.bodyType {
        case .tiny: 1
        case .balanced: 0
        case .chonky: -1
        }
        if bodyInset < 0 {
            for x in 3...12 {
                paint(x, 11, primary.opacity(0.92))
            }
        } else if bodyInset > 0 {
            for x in 4...11 {
                paint(x, 12, outline)
            }
        }

        switch appearance.tailShape {
        case .plume:
            for i in 0...4 {
                paint(12 + i, 8 - i / 2, primary)
            }
        case .ringed:
            for i in 0...4 {
                paint(12 + i, 9 - i / 3, i.isMultiple(of: 2) ? secondary : primary)
            }
        case .curled:
            paint(12, 9, primary)
            paint(13, 8, primary)
            paint(14, 8, primary)
            paint(14, 9, secondary)
            paint(13, 10, primary)
        }

        if let outfitColor {
            for x in 4...11 {
                paint(x, 9, outfitColor)
                paint(x, 10, outfitColor)
            }
            paint(4, 8, outfitColor)
            paint(11, 8, outfitColor)
        }

        if let accessoryColor {
            paint(6, 8, accessoryColor)
            paint(7, 8, accessoryColor)
            paint(8, 8, accessoryColor)
        }

        return cells
    }

    static func accentColor(for key: String?) -> Color? {
        guard let key else { return nil }
        return CozyPalette.accent(for: key)
    }
}

extension FurColorPreset {
    var color: Color {
        switch self {
        case .cream: CozyPalette.cream
        case .ginger: CozyPalette.ginger
        case .cocoa: CozyPalette.cocoa
        case .charcoal: CozyPalette.charcoal
        case .snow: CozyPalette.snow
        case .calico: CozyPalette.calico
        }
    }
}

extension EyeColorPreset {
    var color: Color {
        switch self {
        case .jade: CozyPalette.jade
        case .amber: CozyPalette.amber
        case .sky: CozyPalette.sky
        case .coffee: CozyPalette.coffee
        }
    }
}
