import Foundation

enum FurColorPreset: String, Codable, CaseIterable, Identifiable {
    case cream
    case ginger
    case cocoa
    case charcoal
    case snow
    case calico

    var id: String { rawValue }

    var title: String {
        switch self {
        case .cream: "奶油"
        case .ginger: "橘子"
        case .cocoa: "可可"
        case .charcoal: "墨灰"
        case .snow: "雪团"
        case .calico: "三花"
        }
    }
}

enum CatPatternPreset: String, Codable, CaseIterable, Identifiable {
    case solid
    case striped
    case patches
    case socks
    case cloudy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .solid: "纯色"
        case .striped: "虎斑"
        case .patches: "斑块"
        case .socks: "白袜"
        case .cloudy: "云朵"
        }
    }
}

enum FacePatternPreset: String, Codable, CaseIterable, Identifiable {
    case plain
    case mask
    case blaze
    case noseDot

    var id: String { rawValue }

    var title: String {
        switch self {
        case .plain: "清爽脸"
        case .mask: "面罩"
        case .blaze: "额头白斑"
        case .noseDot: "鼻尖点点"
        }
    }
}

enum EyeColorPreset: String, Codable, CaseIterable, Identifiable {
    case jade
    case amber
    case sky
    case coffee

    var id: String { rawValue }

    var title: String {
        switch self {
        case .jade: "翡翠"
        case .amber: "琥珀"
        case .sky: "晴空"
        case .coffee: "咖啡"
        }
    }
}

enum EarShapePreset: String, Codable, CaseIterable, Identifiable {
    case round
    case pointy
    case fluffy

    var id: String { rawValue }

    var title: String {
        switch self {
        case .round: "圆耳"
        case .pointy: "尖耳"
        case .fluffy: "绒耳"
        }
    }
}

enum BodyTypePreset: String, Codable, CaseIterable, Identifiable {
    case tiny
    case balanced
    case chonky

    var id: String { rawValue }

    var title: String {
        switch self {
        case .tiny: "小巧"
        case .balanced: "匀称"
        case .chonky: "圆滚滚"
        }
    }
}

enum TailShapePreset: String, Codable, CaseIterable, Identifiable {
    case plume
    case ringed
    case curled

    var id: String { rawValue }

    var title: String {
        switch self {
        case .plume: "蓬尾"
        case .ringed: "环尾"
        case .curled: "卷尾"
        }
    }
}

enum MoodPreset: String, Codable, CaseIterable, Identifiable {
    case relaxed
    case playful
    case sleepy
    case proud

    var id: String { rawValue }

    var title: String {
        switch self {
        case .relaxed: "软乎乎"
        case .playful: "想撒欢"
        case .sleepy: "困困的"
        case .proud: "得意洋洋"
        }
    }
}

enum WallpaperStyle: String, Codable, CaseIterable, Identifiable {
    case sunny
    case mint
    case berry

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sunny: "奶油阳光"
        case .mint: "薄荷清晨"
        case .berry: "莓果黄昏"
        }
    }
}

enum HomeSlot: String, Codable, CaseIterable, Identifiable {
    case bed
    case window
    case rug
    case wall

    var id: String { rawValue }

    var title: String {
        switch self {
        case .bed: "睡觉角落"
        case .window: "窗边"
        case .rug: "地面"
        case .wall: "墙面"
        }
    }
}

enum AlbumCategory: String, Codable, CaseIterable, Identifiable {
    case souvenir
    case photo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .souvenir: "收藏品"
        case .photo: "照片卡"
        }
    }
}

enum TripStatus: String, Codable, CaseIterable {
    case idle
    case traveling
    case readyToClaim
}

struct CatAppearanceSeed: Codable, Equatable {
    var primaryFur: FurColorPreset
    var secondaryFur: FurColorPreset
    var pattern: CatPatternPreset
    var facePattern: FacePatternPreset
    var eyeColor: EyeColorPreset
    var earShape: EarShapePreset
    var bodyType: BodyTypePreset
    var tailShape: TailShapePreset
    var notes: String
}

struct CatAppearance: Codable, Equatable {
    var primaryFur: FurColorPreset
    var secondaryFur: FurColorPreset
    var pattern: CatPatternPreset
    var facePattern: FacePatternPreset
    var eyeColor: EyeColorPreset
    var earShape: EarShapePreset
    var bodyType: BodyTypePreset
    var tailShape: TailShapePreset
    var headScale: Double
    var earScale: Double
    var eyeSpacing: Double
    var tailLength: Double
    var accessoryID: String?
    var lastSeedNotes: String

    enum CodingKeys: String, CodingKey {
        case primaryFur
        case secondaryFur
        case pattern
        case facePattern
        case eyeColor
        case earShape
        case bodyType
        case tailShape
        case headScale
        case earScale
        case eyeSpacing
        case tailLength
        case accessoryID
        case lastSeedNotes
    }

    static let starter = CatAppearance(
        primaryFur: .cream,
        secondaryFur: .ginger,
        pattern: .socks,
        facePattern: .blaze,
        eyeColor: .jade,
        earShape: .round,
        bodyType: .balanced,
        tailShape: .plume,
        headScale: 1.0,
        earScale: 1.0,
        eyeSpacing: 1.0,
        tailLength: 1.0,
        accessoryID: "bell-collar",
        lastSeedNotes: "温柔的小猫初始造型。"
    )

    init(
        primaryFur: FurColorPreset,
        secondaryFur: FurColorPreset,
        pattern: CatPatternPreset,
        facePattern: FacePatternPreset,
        eyeColor: EyeColorPreset,
        earShape: EarShapePreset,
        bodyType: BodyTypePreset,
        tailShape: TailShapePreset,
        headScale: Double,
        earScale: Double,
        eyeSpacing: Double,
        tailLength: Double,
        accessoryID: String?,
        lastSeedNotes: String
    ) {
        self.primaryFur = primaryFur
        self.secondaryFur = secondaryFur
        self.pattern = pattern
        self.facePattern = facePattern
        self.eyeColor = eyeColor
        self.earShape = earShape
        self.bodyType = bodyType
        self.tailShape = tailShape
        self.headScale = headScale
        self.earScale = earScale
        self.eyeSpacing = eyeSpacing
        self.tailLength = tailLength
        self.accessoryID = accessoryID
        self.lastSeedNotes = lastSeedNotes
    }

    init(seed: CatAppearanceSeed, accessoryID: String? = nil) {
        self.init(
            primaryFur: seed.primaryFur,
            secondaryFur: seed.secondaryFur,
            pattern: seed.pattern,
            facePattern: seed.facePattern,
            eyeColor: seed.eyeColor,
            earShape: seed.earShape,
            bodyType: seed.bodyType,
            tailShape: seed.tailShape,
            headScale: 1.0,
            earScale: 1.0,
            eyeSpacing: 1.0,
            tailLength: 1.0,
            accessoryID: accessoryID,
            lastSeedNotes: seed.notes
        )
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        primaryFur = try container.decode(FurColorPreset.self, forKey: .primaryFur)
        secondaryFur = try container.decode(FurColorPreset.self, forKey: .secondaryFur)
        pattern = try container.decode(CatPatternPreset.self, forKey: .pattern)
        facePattern = try container.decode(FacePatternPreset.self, forKey: .facePattern)
        eyeColor = try container.decode(EyeColorPreset.self, forKey: .eyeColor)
        earShape = try container.decode(EarShapePreset.self, forKey: .earShape)
        bodyType = try container.decode(BodyTypePreset.self, forKey: .bodyType)
        tailShape = try container.decode(TailShapePreset.self, forKey: .tailShape)
        headScale = try container.decodeIfPresent(Double.self, forKey: .headScale) ?? 1.0
        earScale = try container.decodeIfPresent(Double.self, forKey: .earScale) ?? 1.0
        eyeSpacing = try container.decodeIfPresent(Double.self, forKey: .eyeSpacing) ?? 1.0
        tailLength = try container.decodeIfPresent(Double.self, forKey: .tailLength) ?? 1.0
        accessoryID = try container.decodeIfPresent(String.self, forKey: .accessoryID)
        lastSeedNotes = try container.decode(String.self, forKey: .lastSeedNotes)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(primaryFur, forKey: .primaryFur)
        try container.encode(secondaryFur, forKey: .secondaryFur)
        try container.encode(pattern, forKey: .pattern)
        try container.encode(facePattern, forKey: .facePattern)
        try container.encode(eyeColor, forKey: .eyeColor)
        try container.encode(earShape, forKey: .earShape)
        try container.encode(bodyType, forKey: .bodyType)
        try container.encode(tailShape, forKey: .tailShape)
        try container.encode(headScale, forKey: .headScale)
        try container.encode(earScale, forKey: .earScale)
        try container.encode(eyeSpacing, forKey: .eyeSpacing)
        try container.encode(tailLength, forKey: .tailLength)
        try container.encodeIfPresent(accessoryID, forKey: .accessoryID)
        try container.encode(lastSeedNotes, forKey: .lastSeedNotes)
    }
}

struct WardrobeState: Codable, Equatable {
    var equippedOutfitID: String?
    var equippedAccessoryID: String?
}

struct HomeState: Codable, Equatable {
    var wallpaper: WallpaperStyle
    var placements: [String: String]
}

struct TripPlan: Codable, Equatable, Hashable {
    var destinationID: String
    var durationMinutes: Int
    var startedAt: Date
    var endsAt: Date
}

struct TripRewardPack: Codable, Equatable, Hashable {
    var coins: Int
    var souvenirIDs: [String]
    var photoCardIDs: [String]
    var duplicateCoins: Int
    var summary: String
}

struct TripState: Codable, Equatable {
    var status: TripStatus
    var currentPlan: TripPlan?
    var pendingReward: TripRewardPack?
    var lastReturnedAt: Date?

    static let idle = TripState(status: .idle, currentPlan: nil, pendingReward: nil, lastReturnedAt: nil)
}

struct AlbumEntry: Codable, Equatable, Hashable, Identifiable {
    var contentID: String
    var category: AlbumCategory
    var firstFoundAt: Date
    var timesFound: Int

    var id: String {
        "\(category.rawValue)-\(contentID)"
    }
}

struct DailyTaskState: Codable, Equatable {
    var dayKey: String
    var pettedToday: Bool
    var fedToday: Bool
    var traveledToday: Bool

    static func fresh(dayKey: String) -> DailyTaskState {
        DailyTaskState(dayKey: dayKey, pettedToday: false, fedToday: false, traveledToday: false)
    }

    var completedCount: Int {
        [pettedToday, fedToday, traveledToday].filter { $0 }.count
    }
}

struct CatProfile: Codable, Equatable, Identifiable {
    var id: UUID
    var name: String
    var createdAt: Date
    var referencePhotoFilename: String?
    var appearance: CatAppearance
    var mood: MoodPreset
    var intimacy: Int
    var homeState: HomeState
    var wardrobeState: WardrobeState
    var tripState: TripState
    var albumEntries: [AlbumEntry]
    var dailyTasks: DailyTaskState
    var lastInteractionMessage: String
    var lastPetAt: Date?
    var lastFedAt: Date?
    var lastPlayedAt: Date?
}

struct GlobalUnlocks: Codable, Equatable {
    var outfitIDs: Set<String>
    var accessoryIDs: Set<String>
    var furnitureIDs: Set<String>

    static let starter = GlobalUnlocks(
        outfitIDs: ["linen-apron"],
        accessoryIDs: ["bell-collar"],
        furnitureIDs: ["cotton-bed", "sun-window"]
    )
}

struct DeveloperSettings: Codable, Equatable {
    var preferredAIModel: String
    var lastGenerationError: String?

    static let starter = DeveloperSettings(preferredAIModel: "gpt-4.1-mini", lastGenerationError: nil)
}

struct GameSaveState: Codable, Equatable {
    var cats: [CatProfile]
    var selectedCatID: UUID?
    var coins: Int
    var globalUnlocks: GlobalUnlocks
    var developerSettings: DeveloperSettings

    static let empty = GameSaveState(
        cats: [],
        selectedCatID: nil,
        coins: 120,
        globalUnlocks: .starter,
        developerSettings: .starter
    )
}

extension CatProfile {
    var activeAccessoryID: String? {
        appearance.accessoryID ?? wardrobeState.equippedAccessoryID
    }
}
