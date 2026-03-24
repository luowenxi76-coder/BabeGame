import Foundation

@MainActor
final class GameSession: ObservableObject {
    let boardIndices = Array(0..<9)

    @Published private(set) var score = 0
    @Published private(set) var round = 1
    @Published private(set) var streak = 0
    @Published private(set) var winningIndex = Int.random(in: 0..<9)
    @Published private(set) var revealedIndex: Int?
    @Published private(set) var statusText = "Find the hidden star to win the round."

    var isRoundResolved: Bool {
        revealedIndex != nil
    }

    func tapTile(at index: Int) {
        guard revealedIndex == nil else { return }

        revealedIndex = index

        if index == winningIndex {
            score += 10
            streak += 1
            statusText = "Nice! You found the hidden star."
        } else {
            streak = 0
            statusText = "Not this one. Take a breath and try the next round."
        }
    }

    func advanceRound() {
        round += 1
        revealedIndex = nil
        winningIndex = Int.random(in: boardIndices.indices)
        statusText = "Round \(round). Find the hidden star."
    }

    func resetGame() {
        score = 0
        round = 1
        streak = 0
        revealedIndex = nil
        winningIndex = Int.random(in: boardIndices.indices)
        statusText = "Fresh start. Find the hidden star to win the round."
    }
}
