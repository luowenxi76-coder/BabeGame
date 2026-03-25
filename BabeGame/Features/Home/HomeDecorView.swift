import SwiftUI

struct HomeDecorView: View {
    @EnvironmentObject private var store: GameStore
    @State private var selectedSlot: HomeSlot = .bed

    var body: some View {
        ZStack {
            CozyBackground()

            if let cat = store.currentCat {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        CozySectionTitle(
                            eyebrow: "Decor",
                            title: GameText.decorTitle,
                            subtitle: "每只猫的房间布局独立保存。首版先做一个主房间和固定位置的家具摆放。"
                        )

                        CozyCard(accent: CozyPalette.mint) {
                            InteractiveHomeScene3DView(cat: cat) { target in
                                switch target {
                                case .cat:
                                    store.petCurrentCat()
                                case .bowl:
                                    store.feedCurrentCat()
                                case .toy:
                                    store.playWithCurrentCat()
                                }
                            }
                            .frame(height: 340)
                            CurrencyBadge(coins: store.saveState.coins)
                        }

                        CozyCard(accent: CozyPalette.butter) {
                            Text("墙纸氛围")
                                .font(.headline)

                            ForEach(WallpaperStyle.allCases) { wallpaper in
                                Button {
                                    store.setWallpaper(wallpaper)
                                } label: {
                                    HStack {
                                        Text(wallpaper.title)
                                        Spacer()
                                        if cat.homeState.wallpaper == wallpaper {
                                            Image(systemName: "checkmark.circle.fill")
                                        }
                                    }
                                }
                                .buttonStyle(CozyPrimaryButtonStyle(accent: wallpaper == .mint ? CozyPalette.mint : wallpaper == .berry ? CozyPalette.berry : CozyPalette.peach))
                            }
                        }

                        CozyCard(accent: CozyPalette.pearl) {
                            Text("布置区域")
                                .font(.headline)

                            Picker("区域", selection: $selectedSlot) {
                                ForEach(HomeSlot.allCases) { slot in
                                    Text(slot.title).tag(slot)
                                }
                            }
                            .pickerStyle(.segmented)

                            let currentFurnitureID = cat.homeState.placements[selectedSlot.rawValue]
                            if let currentFurnitureID, let current = GameContent.furniture(id: currentFurnitureID) {
                                Label("当前摆放：\(current.title)", systemImage: "checkmark.circle.fill")
                                    .font(.subheadline)
                                    .foregroundStyle(CozyPalette.ink.opacity(0.72))
                            }

                            ForEach(GameContent.furniture(for: selectedSlot)) { furniture in
                                CozyCard(accent: CozyPalette.accent(for: furniture.accentKey)) {
                                    Text(furniture.title)
                                        .font(.headline)
                                    Text(furniture.subtitle)
                                        .font(.footnote)
                                        .foregroundStyle(CozyPalette.ink.opacity(0.65))

                                    LabelValueRow(label: "价格", value: furniture.cost == 0 ? "默认解锁" : "\(furniture.cost) 金币")

                                    Button(buttonTitle(for: furniture, currentFurnitureID: currentFurnitureID)) {
                                        store.purchaseOrPlaceFurniture(furniture.id, in: selectedSlot)
                                    }
                                    .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.accent(for: furniture.accentKey)))
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle(GameText.decorTitle)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func buttonTitle(for furniture: FurnitureDefinition, currentFurnitureID: String?) -> String {
        if currentFurnitureID == furniture.id {
            return "已摆放"
        }
        if store.isFurnitureUnlocked(furniture.id) {
            return "摆进房间"
        }
        return "购买并摆放"
    }
}
