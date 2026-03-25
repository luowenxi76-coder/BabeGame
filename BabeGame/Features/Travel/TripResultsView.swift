import SwiftUI

struct TripResultsView: View {
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            CozyBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    CozySectionTitle(
                        eyebrow: "Return",
                        title: GameText.tripResults,
                        subtitle: "旅行奖励只会领取一次。收藏品重复时会自动折算成金币。"
                    )

                    if let cat = store.currentCat,
                       cat.tripState.status == .readyToClaim,
                       let reward = cat.tripState.pendingReward,
                       let plan = cat.tripState.currentPlan {
                        CozyCard(accent: CozyPalette.peach) {
                            LabelValueRow(label: "目的地", value: GameContent.destination(id: plan.destinationID)?.title ?? "旅行地")
                            LabelValueRow(label: "基础金币", value: "\(reward.coins)")
                            LabelValueRow(label: "收藏品", value: reward.souvenirIDs.isEmpty ? "无" : "\(reward.souvenirIDs.count) 件")
                            LabelValueRow(label: "照片卡", value: reward.photoCardIDs.isEmpty ? "无" : "\(reward.photoCardIDs.count) 张")

                            Text(reward.summary)
                                .font(.subheadline)
                                .foregroundStyle(CozyPalette.ink.opacity(0.72))
                        }

                        if !reward.souvenirIDs.isEmpty {
                            CozyCard(accent: CozyPalette.mint) {
                                Text("带回的收藏品")
                                    .font(.headline)

                                ForEach(reward.souvenirIDs, id: \.self) { souvenirID in
                                    Text(GameContent.collectible(id: souvenirID)?.title ?? souvenirID)
                                        .font(.subheadline)
                                        .foregroundStyle(CozyPalette.ink)
                                }
                            }
                        }

                        if !reward.photoCardIDs.isEmpty {
                            CozyCard(accent: CozyPalette.berry) {
                                Text("带回的照片卡")
                                    .font(.headline)

                                ForEach(reward.photoCardIDs, id: \.self) { photoID in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(GameContent.photoCard(id: photoID)?.title ?? photoID)
                                            .font(.subheadline.weight(.semibold))
                                        Text(GameContent.photoCard(id: photoID)?.caption ?? "")
                                            .font(.footnote)
                                            .foregroundStyle(CozyPalette.ink.opacity(0.62))
                                    }
                                }
                            }
                        }

                        Button("领取回家礼物") {
                            store.claimTripReward()
                            dismiss()
                        }
                        .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.butter))
                    } else {
                        CozyCard(accent: CozyPalette.mint) {
                            Text("现在还没有待领取的旅行结果。")
                                .font(.headline)
                        }
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(GameText.tripResults)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.refreshTripStates()
        }
    }
}
