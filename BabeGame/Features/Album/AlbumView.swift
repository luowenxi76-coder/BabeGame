import SwiftUI

struct AlbumView: View {
    @EnvironmentObject private var store: GameStore
    @State private var selectedCategory: AlbumCategory = .souvenir

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        ZStack {
            CozyBackground()

            if let cat = store.currentCat {
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        CozySectionTitle(
                            eyebrow: "Album",
                            title: "\(cat.name) 的收藏册",
                            subtitle: "旅行带回的收藏品和照片卡都会自动归档。"
                        )

                        CozyCard(accent: CozyPalette.butter) {
                            Picker("类型", selection: $selectedCategory) {
                                ForEach(AlbumCategory.allCases) { category in
                                    Text(category.title).tag(category)
                                }
                            }
                            .pickerStyle(.segmented)

                            LabelValueRow(label: "完成度", value: "\(collectedCount(for: cat, category: selectedCategory)) / \(totalCount(for: selectedCategory))")
                        }

                        LazyVGrid(columns: columns, spacing: 14) {
                            if selectedCategory == .souvenir {
                                ForEach(GameContent.collectibles) { item in
                                    albumCard(
                                        title: item.title,
                                        subtitle: item.blurb,
                                        accent: CozyPalette.accent(for: destinationAccentKey(for: item.destinationID)),
                                        entry: store.albumEntry(for: item.id, category: .souvenir)
                                    )
                                }
                            } else {
                                ForEach(GameContent.photoCards) { card in
                                    albumCard(
                                        title: card.title,
                                        subtitle: card.caption,
                                        accent: CozyPalette.accent(for: destinationAccentKey(for: card.destinationID)),
                                        entry: store.albumEntry(for: card.id, category: .photo)
                                    )
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .navigationTitle(GameText.albumTab)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func collectedCount(for cat: CatProfile, category: AlbumCategory) -> Int {
        cat.albumEntries.filter { $0.category == category }.count
    }

    private func totalCount(for category: AlbumCategory) -> Int {
        category == .souvenir ? GameContent.collectibles.count : GameContent.photoCards.count
    }

    private func destinationAccentKey(for destinationID: String) -> String {
        GameContent.destination(id: destinationID)?.accentKey ?? "peach"
    }

    @ViewBuilder
    private func albumCard(title: String, subtitle: String, accent: Color, entry: AlbumEntry?) -> some View {
        CozyCard(accent: accent) {
            if let entry {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(CozyPalette.ink)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(CozyPalette.ink.opacity(0.66))

                LabelValueRow(label: "首次获得", value: entry.firstFoundAt.cozyDayText)
                LabelValueRow(label: "获得次数", value: "\(entry.timesFound)")
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Image(systemName: "questionmark.app.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(accent)

                    Text("尚未发现")
                        .font(.headline)
                        .foregroundStyle(CozyPalette.ink)

                    Text("继续旅行就有机会把它带回家。")
                        .font(.footnote)
                        .foregroundStyle(CozyPalette.ink.opacity(0.62))
                }
            }
        }
    }
}
