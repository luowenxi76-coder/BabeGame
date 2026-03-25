import SwiftUI

struct TripPlannerView: View {
    @EnvironmentObject private var store: GameStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDestinationID = GameContent.destinations.first?.id ?? ""
    @State private var selectedDuration = 60

    var body: some View {
        ZStack {
            CozyBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    CozySectionTitle(
                        eyebrow: "Trip",
                        title: GameText.tripPlanner,
                        subtitle: "首版旅行是简化系统。选目的地和时长就能出发，回家时会带来金币、收藏品和照片卡。"
                    )

                    if let cat = store.currentCat, cat.tripState.status != .idle {
                        CozyCard(accent: CozyPalette.berry) {
                            Text("现在已经有旅程在进行中了。")
                                .font(.headline)
                            if cat.tripState.status == .readyToClaim {
                                NavigationLink(GameText.tripResults) {
                                    TripResultsView()
                                }
                                .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.peach))
                            }
                        }
                    } else {
                        CozyCard(accent: CozyPalette.mint) {
                            Text("选择目的地")
                                .font(.headline)

                            ForEach(GameContent.destinations) { destination in
                                Button {
                                    selectedDestinationID = destination.id
                                } label: {
                                    HStack(alignment: .top) {
                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(destination.title)
                                                .font(.headline)
                                                .foregroundStyle(CozyPalette.ink)
                                            Text(destination.subtitle)
                                                .font(.footnote)
                                                .foregroundStyle(CozyPalette.ink.opacity(0.68))
                                        }

                                        Spacer()

                                        Image(systemName: selectedDestinationID == destination.id ? "checkmark.circle.fill" : "circle")
                                            .foregroundStyle(CozyPalette.accent(for: destination.accentKey))
                                    }
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .fill(CozyPalette.accent(for: destination.accentKey).opacity(0.22))
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        CozyCard(accent: CozyPalette.butter) {
                            Text("选择时长")
                                .font(.headline)

                            HStack(spacing: 12) {
                                ForEach(GameContent.tripDurations, id: \.self) { duration in
                                    Button {
                                        selectedDuration = duration
                                    } label: {
                                        Text("\(duration) 分钟")
                                            .frame(maxWidth: .infinity)
                                    }
                                    .buttonStyle(CozyPrimaryButtonStyle(accent: selectedDuration == duration ? CozyPalette.butter : CozyPalette.paper))
                                }
                            }

                            Text("时长越长，带回照片卡和额外收藏品的概率越高。")
                                .font(.footnote)
                                .foregroundStyle(CozyPalette.ink.opacity(0.66))
                        }

                        Button("出发吧") {
                            store.startTrip(destinationID: selectedDestinationID, durationMinutes: selectedDuration)
                            dismiss()
                        }
                        .buttonStyle(CozyPrimaryButtonStyle(accent: CozyPalette.peach))
                    }
                }
                .padding(20)
            }
        }
        .navigationTitle(GameText.tripPlanner)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            store.refreshTripStates()
            if selectedDestinationID.isEmpty {
                selectedDestinationID = GameContent.destinations.first?.id ?? ""
            }
        }
    }
}
