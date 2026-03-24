import SwiftUI

struct GameView: View {
    @EnvironmentObject private var session: GameSession

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.97, green: 0.93, blue: 0.83),
                    Color(red: 0.98, green: 0.74, blue: 0.53)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                summaryBar

                VStack(alignment: .leading, spacing: 10) {
                    Text("Find the star")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.black.opacity(0.84))

                    Text(session.statusText)
                        .font(.subheadline)
                        .foregroundStyle(Color.black.opacity(0.65))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(session.boardIndices, id: \.self) { index in
                        Button {
                            session.tapTile(at: index)
                        } label: {
                            TileView(
                                revealed: session.revealedIndex == index,
                                winning: session.winningIndex == index
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(session.isRoundResolved)
                    }
                }

                VStack(spacing: 12) {
                    Button(session.isRoundResolved ? "Next Round" : "Waiting For Your Pick") {
                        session.advanceRound()
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(session.isRoundResolved ? Color.black.opacity(0.82) : Color.black.opacity(0.30))
                    )
                    .disabled(!session.isRoundResolved)

                    Button("Reset Session") {
                        session.resetGame()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.black.opacity(0.74))
                }
            }
            .padding(20)
        }
        .navigationTitle("Prototype")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var summaryBar: some View {
        HStack(spacing: 12) {
            MetricPill(title: "Score", value: "\(session.score)")
            MetricPill(title: "Round", value: "\(session.round)")
            MetricPill(title: "Streak", value: "\(session.streak)")
        }
    }
}

private struct MetricPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.black.opacity(0.56))

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.84))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.72))
        )
    }
}

private struct TileView: View {
    let revealed: Bool
    let winning: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(tileFill)
            .frame(height: 104)
            .overlay {
                Image(systemName: symbolName)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(symbolColor)
            }
    }

    private var tileFill: LinearGradient {
        if revealed && winning {
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.78, blue: 0.18), Color(red: 0.98, green: 0.49, blue: 0.11)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else if revealed {
            return LinearGradient(
                colors: [Color(red: 0.42, green: 0.49, blue: 0.62), Color(red: 0.22, green: 0.27, blue: 0.36)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [Color.white.opacity(0.78), Color.white.opacity(0.42)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var symbolName: String {
        if !revealed { return "questionmark" }
        return winning ? "sparkles" : "xmark"
    }

    private var symbolColor: Color {
        revealed ? .white : Color.black.opacity(0.45)
    }
}

#Preview {
    NavigationStack {
        GameView()
            .environmentObject(GameSession())
    }
}
