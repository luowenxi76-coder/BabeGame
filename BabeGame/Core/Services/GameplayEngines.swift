import Foundation

protocol ClockProvider {
    var now: Date { get }
}

struct SystemClockProvider: ClockProvider {
    var now: Date { Date() }
}

struct TripResolutionEngine {
    func prepareReward(for plan: TripPlan, cat: CatProfile) -> TripRewardPack {
        let destination = GameContent.destination(id: plan.destinationID) ?? GameContent.destinations[0]
        let durationBonus = switch plan.durationMinutes {
        case 120: 34
        case 60: 18
        default: 8
        }

        var souvenirIDs: [String] = []
        if let primary = destination.souvenirIDs.randomElement() {
            souvenirIDs.append(primary)
        }
        if plan.durationMinutes == 120, let extra = destination.souvenirIDs.randomElement() {
            souvenirIDs.append(extra)
        }

        var photoCardIDs: [String] = []
        let photoChance = switch plan.durationMinutes {
        case 120: 0.72
        case 60: 0.48
        default: 0.33
        }
        if Double.random(in: 0...1) < photoChance, let card = destination.photoCardIDs.randomElement() {
            photoCardIDs.append(card)
        }

        let intimacyBonus = max(0, cat.intimacy / 6)
        let coins = destination.baseCoinReward + durationBonus + intimacyBonus
        let summary = "\(cat.name)从\(destination.title)带回了一小包回忆。"

        return TripRewardPack(
            coins: coins,
            souvenirIDs: souvenirIDs,
            photoCardIDs: photoCardIDs,
            duplicateCoins: 0,
            summary: summary
        )
    }
}

struct RewardEngine {
    mutating func claim(_ reward: TripRewardPack, for cat: inout CatProfile, claimedAt: Date) -> Int {
        var duplicateCoins = 0

        for souvenirID in reward.souvenirIDs {
            if let index = cat.albumEntries.firstIndex(where: { $0.contentID == souvenirID && $0.category == .souvenir }) {
                cat.albumEntries[index].timesFound += 1
                duplicateCoins += 12
            } else {
                cat.albumEntries.append(
                    AlbumEntry(contentID: souvenirID, category: .souvenir, firstFoundAt: claimedAt, timesFound: 1)
                )
            }
        }

        for photoID in reward.photoCardIDs {
            if let index = cat.albumEntries.firstIndex(where: { $0.contentID == photoID && $0.category == .photo }) {
                cat.albumEntries[index].timesFound += 1
            } else {
                cat.albumEntries.append(
                    AlbumEntry(contentID: photoID, category: .photo, firstFoundAt: claimedAt, timesFound: 1)
                )
            }
        }

        return duplicateCoins
    }
}
