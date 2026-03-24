import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var session: GameSession

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.10, green: 0.13, blue: 0.28),
                    Color(red: 0.22, green: 0.43, blue: 0.66),
                    Color(red: 0.91, green: 0.42, blue: 0.32)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    header
                    snapshotCard
                    NavigationLink {
                        GameView()
                    } label: {
                        Label("Start Prototype", systemImage: "play.fill")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color.black.opacity(0.24))
                            )
                    }

                    tipsCard
                }
                .padding(24)
            }
        }
        .navigationBarHidden(true)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("BabeGame")
                .font(.system(size: 42, weight: .black, design: .rounded))
                .foregroundStyle(.white)

            Text("A bright SwiftUI game starter with a simple hidden-star loop. We can build levels, sound, and polish on top of this.")
                .font(.body)
                .foregroundStyle(.white.opacity(0.86))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var snapshotCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Session Snapshot")
                .font(.headline)
                .foregroundStyle(.white)

            HStack(spacing: 12) {
                StatCard(title: "Score", value: "\(session.score)")
                StatCard(title: "Round", value: "\(session.round)")
                StatCard(title: "Streak", value: "\(session.streak)")
            }

            Text(session.statusText)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.white.opacity(0.14))
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(Color.white.opacity(0.18), lineWidth: 1)
                )
        )
    }

    private var tipsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("What We Have Now")
                .font(.headline)
                .foregroundStyle(.white)

            Text("1. Native iOS app structure with SwiftUI")
            Text("2. A simple playable prototype loop")
            Text("3. A clean base for art, sound, and progression")
        }
        .font(.subheadline)
        .foregroundStyle(.white.opacity(0.88))
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color.black.opacity(0.18))
        )
    }
}

private struct StatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.72))

            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.10))
        )
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(GameSession())
    }
}
