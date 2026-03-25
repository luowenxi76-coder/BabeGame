import SwiftUI

struct WardrobeView: View {
    @EnvironmentObject private var store: GameStore

    var body: some View {
        ZStack {
            CozyBackground()

            if let cat = store.currentCat {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        CozySectionTitle(
                            eyebrow: "Wardrobe",
                            title: "\(cat.name) 的衣橱",
                            subtitle: "换装是长期陪伴的一部分。购买是全局解锁，每只猫会记住自己当前穿着。"
                        )

                        CozyCard(accent: CozyPalette.peach) {
                            HStack {
                                LowPolyCatPreview3DView(
                                    appearance: cat.appearance,
                                    outfit: GameContent.outfit(id: cat.wardrobeState.equippedOutfitID),
                                    accessory: GameContent.accessory(id: cat.activeAccessoryID)
                                )
                                .frame(width: 180, height: 180)
                                .background(
                                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                                        .fill(CozyPalette.paper.opacity(0.76))
                                )
                                Spacer()
                                CurrencyBadge(coins: store.saveState.coins)
                            }

                            LabelValueRow(label: "当前衣服", value: GameContent.outfit(id: cat.wardrobeState.equippedOutfitID)?.title ?? "未穿搭")
                            LabelValueRow(label: "当前配饰", value: GameContent.accessory(id: cat.activeAccessoryID)?.title ?? "不佩戴")
                        }

                        CozyCard(accent: CozyPalette.mint) {
                            Text("服装")
                                .font(.headline)

                            ForEach(GameContent.outfits) { outfit in
                                wardrobeItemCard(
                                    title: outfit.title,
                                    subtitle: outfit.subtitle,
                                    accent: CozyPalette.accent(for: outfit.accentKey),
                                    cost: outfit.cost,
                                    isSelected: cat.wardrobeState.equippedOutfitID == outfit.id,
                                    isUnlocked: store.isOutfitUnlocked(outfit.id),
                                    actionTitle: wardrobeButtonTitle(
                                        isUnlocked: store.isOutfitUnlocked(outfit.id),
                                        isSelected: cat.wardrobeState.equippedOutfitID == outfit.id
                                    )
                                ) {
                                    store.purchaseOrEquipOutfit(outfit.id)
                                }
                            }
                        }

                        CozyCard(accent: CozyPalette.berry) {
                            Text("配饰")
                                .font(.headline)

                            ForEach(GameContent.accessories) { accessory in
                                wardrobeItemCard(
                                    title: accessory.title,
                                    subtitle: accessory.subtitle,
                                    accent: CozyPalette.accent(for: accessory.accentKey),
                                    cost: accessory.cost,
                                    isSelected: cat.activeAccessoryID == accessory.id,
                                    isUnlocked: store.isAccessoryUnlocked(accessory.id),
                                    actionTitle: wardrobeButtonTitle(
                                        isUnlocked: store.isAccessoryUnlocked(accessory.id),
                                        isSelected: cat.activeAccessoryID == accessory.id
                                    )
                                ) {
                                    store.purchaseOrEquipAccessory(accessory.id)
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle(GameText.wardrobeTab)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func wardrobeButtonTitle(isUnlocked: Bool, isSelected: Bool) -> String {
        if isSelected {
            return "正在穿着"
        }
        return isUnlocked ? "穿上" : "购买并穿上"
    }

    @ViewBuilder
    private func wardrobeItemCard(
        title: String,
        subtitle: String,
        accent: Color,
        cost: Int,
        isSelected: Bool,
        isUnlocked: Bool,
        actionTitle: String,
        action: @escaping () -> Void
    ) -> some View {
        CozyCard(accent: accent) {
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(CozyPalette.ink.opacity(0.65))

            LabelValueRow(label: "价格", value: cost == 0 ? "默认解锁" : "\(cost) 金币")
            if isSelected {
                TagPill(label: "当前穿戴", accent: accent.opacity(0.8))
            }

            Button(actionTitle, action: action)
                .buttonStyle(CozyPrimaryButtonStyle(accent: accent))
        }
    }
}
