import SwiftUI

struct CatProfilesView: View {
    @EnvironmentObject private var store: GameStore
    @State private var isPresentingCreator = false

    var body: some View {
        ZStack {
            CozyBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    CozySectionTitle(
                        eyebrow: "Profiles",
                        title: store.saveState.cats.isEmpty ? "把你的猫咪带进手机里" : "猫咪档案",
                        subtitle: store.saveState.cats.isEmpty
                            ? "先创建第一只猫，我们会把照片生成的造型和后续成长都存进同一个本地档案里。"
                            : "每只猫都会有独立的旅行、图鉴、家园和穿搭记录。"
                    )

                    if store.saveState.cats.isEmpty {
                        EmptyStateCard(
                            title: "先创建第一只猫咪",
                            subtitle: "可以先上传照片让 AI 提取造型，也可以直接手动捏一只像它的小猫。",
                            buttonTitle: GameText.createCat
                        ) {
                            isPresentingCreator = true
                        }
                    } else {
                        ForEach(store.saveState.cats) { cat in
                            Button {
                                store.switchSelectedCat(to: cat.id)
                            } label: {
                                CozyCard(accent: CozyPalette.accent(for: cat.homeState.wallpaper == .mint ? "mint" : cat.homeState.wallpaper == .berry ? "berry" : "peach")) {
                                    HStack(alignment: .top, spacing: 16) {
                                        PixelCatView(
                                            appearance: cat.appearance,
                                            outfit: GameContent.outfit(id: cat.wardrobeState.equippedOutfitID),
                                            accessory: GameContent.accessory(id: cat.activeAccessoryID),
                                            scale: 6
                                        )

                                        VStack(alignment: .leading, spacing: 10) {
                                            HStack {
                                                Text(cat.name)
                                                    .font(.title3.weight(.bold))
                                                    .foregroundStyle(CozyPalette.ink)

                                                if store.currentCat?.id == cat.id {
                                                    TagPill(label: "当前使用中", accent: CozyPalette.mint)
                                                }
                                            }

                                            Text("创建于 \(cat.createdAt.cozyDayText)")
                                                .font(.subheadline)
                                                .foregroundStyle(CozyPalette.ink.opacity(0.62))

                                            HStack(spacing: 8) {
                                                TagPill(label: cat.mood.title, accent: CozyPalette.peach)
                                                TagPill(label: "亲密度 \(cat.intimacy)", accent: CozyPalette.butter)
                                            }

                                            Text(cat.lastInteractionMessage)
                                                .font(.footnote)
                                                .foregroundStyle(CozyPalette.ink.opacity(0.68))
                                                .fixedSize(horizontal: false, vertical: true)
                                        }
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }

                        Button(GameText.createCat) {
                            isPresentingCreator = true
                        }
                        .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.mint))
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(GameText.manageCats)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !store.saveState.cats.isEmpty {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isPresentingCreator = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $isPresentingCreator) {
            NavigationStack {
                CatStudioView(existingCat: nil)
            }
            .environmentObject(store)
        }
    }
}
