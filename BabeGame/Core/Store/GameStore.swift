import Foundation

@MainActor
final class GameStore: ObservableObject {
    @Published private(set) var saveState: GameSaveState = .empty
    @Published private(set) var isLoaded = false
    @Published var transientNotice = ""

    private let saveStore: SaveStore
    private let keychainStore: KeychainStore
    private let avatarService: CatAvatarGenerationServicing
    private let tripResolutionEngine: TripResolutionEngine
    private let clock: ClockProvider

    private let openAIAccount = "openai-api-key"

    init(
        saveStore: SaveStore = SaveStore(),
        keychainStore: KeychainStore = KeychainStore(service: "com.luowenxi76.BabeGame"),
        avatarService: CatAvatarGenerationServicing = OpenAICatAvatarGenerationService(),
        tripResolutionEngine: TripResolutionEngine = TripResolutionEngine(),
        clock: ClockProvider = SystemClockProvider()
    ) {
        self.saveStore = saveStore
        self.keychainStore = keychainStore
        self.avatarService = avatarService
        self.tripResolutionEngine = tripResolutionEngine
        self.clock = clock
        load()
    }

    var currentCat: CatProfile? {
        guard let selectedCatID = saveState.selectedCatID else { return saveState.cats.first }
        return saveState.cats.first(where: { $0.id == selectedCatID })
    }

    var hasConfiguredAPIKey: Bool {
        keychainStore.read(account: openAIAccount) != nil
    }

    var preferredAIModel: String {
        saveState.developerSettings.preferredAIModel
    }

    func loadReferencePhotoData(named filename: String?) -> Data? {
        guard let filename else { return nil }
        return saveStore.loadReferencePhotoData(named: filename)
    }

    func saveOpenAIKey(_ value: String) {
        do {
            try keychainStore.save(value.trimmingCharacters(in: .whitespacesAndNewlines), account: openAIAccount)
            transientNotice = "开发版 AI Key 已保存到本机钥匙串。"
        } catch {
            transientNotice = "API Key 保存失败，请稍后重试。"
        }
    }

    func clearOpenAIKey() {
        keychainStore.delete(account: openAIAccount)
        transientNotice = "已移除本机保存的 API Key。"
    }

    func updatePreferredAIModel(_ model: String) {
        mutateSave { save in
            save.developerSettings.preferredAIModel = model
        }
    }

    func generateAppearanceSeed(from imageData: Data) async throws -> CatAppearanceSeed {
        guard let apiKey = keychainStore.read(account: openAIAccount) else {
            throw CatAvatarGenerationError.missingAPIKey
        }

        do {
            let seed = try await avatarService.generateSeed(
                from: imageData,
                apiKey: apiKey,
                model: saveState.developerSettings.preferredAIModel
            )
            mutateSave { save in
                save.developerSettings.lastGenerationError = nil
            }
            return seed
        } catch {
            mutateSave { save in
                save.developerSettings.lastGenerationError = error.localizedDescription
            }
            throw error
        }
    }

    func createCat(name: String, appearance: CatAppearance, referencePhotoData: Data?) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let catID = UUID()
        let photoFilename: String?
        if let referencePhotoData {
            photoFilename = try saveStore.saveReferencePhoto(data: referencePhotoData, catID: catID)
        } else {
            photoFilename = nil
        }

        let profile = CatProfile(
            id: catID,
            name: trimmedName.isEmpty ? "新来的小猫" : trimmedName,
            createdAt: clock.now,
            referencePhotoFilename: photoFilename,
            appearance: appearance,
            mood: .relaxed,
            intimacy: 0,
            homeState: HomeState(
                wallpaper: .sunny,
                placements: [
                    HomeSlot.bed.rawValue: "cotton-bed",
                    HomeSlot.window.rawValue: "sun-window"
                ]
            ),
            wardrobeState: WardrobeState(equippedOutfitID: "linen-apron", equippedAccessoryID: appearance.accessoryID ?? "bell-collar"),
            tripState: .idle,
            albumEntries: [],
            dailyTasks: DailyTaskState.fresh(dayKey: currentDayKey()),
            lastInteractionMessage: "今天开始陪它一起住进小房间。",
            lastPetAt: nil,
            lastFedAt: nil,
            lastPlayedAt: nil
        )

        mutateSave { save in
            save.cats.append(profile)
            save.selectedCatID = catID
        }
        transientNotice = "\(profile.name)已经来到家里啦。"
    }

    func updateCurrentCat(name: String, appearance: CatAppearance, newReferencePhotoData: Data?) throws {
        guard let currentCat else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let newPhotoFilename: String?
        if let newReferencePhotoData {
            newPhotoFilename = try saveStore.saveReferencePhoto(data: newReferencePhotoData, catID: currentCat.id)
        } else {
            newPhotoFilename = nil
        }

        mutateCurrentCat { cat in
            cat.name = trimmedName.isEmpty ? cat.name : trimmedName
            cat.appearance = appearance
            cat.wardrobeState.equippedAccessoryID = appearance.accessoryID ?? cat.wardrobeState.equippedAccessoryID
            if let newPhotoFilename {
                cat.referencePhotoFilename = newPhotoFilename
            }
            cat.lastInteractionMessage = "新造型已经保存好了。"
        }
        transientNotice = "猫咪造型已经更新。"
    }

    func switchSelectedCat(to id: UUID) {
        mutateSave { save in
            save.selectedCatID = id
        }
    }

    func petCurrentCat() {
        let now = clock.now
        mutateCurrentCat { cat in
            refreshDailyTasksIfNeeded(for: &cat, now: now)
            cat.mood = .playful
            cat.intimacy += 2
            cat.lastPetAt = now
            cat.dailyTasks.pettedToday = true
            cat.lastInteractionMessage = "被摸摸之后，整只猫都软了下来。"
        }
        mutateSave { save in
            save.coins += 8
        }
        transientNotice = "摸摸成功，获得 8 金币。"
    }

    func feedCurrentCat() {
        guard currentCatFeedCooldown <= 0 else {
            transientNotice = "它刚吃过，还想在旁边慢慢舔爪子。"
            return
        }

        let now = clock.now
        mutateCurrentCat { cat in
            refreshDailyTasksIfNeeded(for: &cat, now: now)
            cat.mood = .relaxed
            cat.intimacy += 3
            cat.lastFedAt = now
            cat.dailyTasks.fedToday = true
            cat.lastInteractionMessage = "小肚子暖暖的，尾巴也慢慢甩起来了。"
        }
        mutateSave { save in
            save.coins += 12
        }
        transientNotice = "喂食完成，获得 12 金币。"
    }

    func playWithCurrentCat() {
        guard currentCatPlayCooldown <= 0 else {
            transientNotice = "它刚疯跑完一圈，正躺着喘气呢。"
            return
        }

        let now = clock.now
        mutateCurrentCat { cat in
            refreshDailyTasksIfNeeded(for: &cat, now: now)
            cat.mood = .playful
            cat.intimacy += 4
            cat.lastPlayedAt = now
            cat.lastInteractionMessage = "玩耍之后心情很好，开始围着你绕圈。"
        }
        mutateSave { save in
            save.coins += 16
        }
        transientNotice = "玩耍完成，获得 16 金币。"
    }

    func purchaseOrEquipOutfit(_ id: String) {
        if !saveState.globalUnlocks.outfitIDs.contains(id), let outfit = GameContent.outfit(id: id) {
            guard saveState.coins >= outfit.cost else {
                transientNotice = "金币还不够，再陪陪小猫吧。"
                return
            }
            mutateSave { save in
                save.coins -= outfit.cost
                save.globalUnlocks.outfitIDs.insert(id)
            }
        }

        mutateCurrentCat { cat in
            cat.wardrobeState.equippedOutfitID = id
            cat.lastInteractionMessage = "今天换上了\(GameContent.outfit(id: id)?.title ?? "新衣服")。"
        }
        transientNotice = "已经穿上新衣服。"
    }

    func purchaseOrEquipAccessory(_ id: String) {
        if !saveState.globalUnlocks.accessoryIDs.contains(id), let accessory = GameContent.accessory(id: id) {
            guard saveState.coins >= accessory.cost else {
                transientNotice = "金币还不够，再完成几次旅行就好了。"
                return
            }
            mutateSave { save in
                save.coins -= accessory.cost
                save.globalUnlocks.accessoryIDs.insert(id)
            }
        }

        mutateCurrentCat { cat in
            cat.appearance.accessoryID = id
            cat.wardrobeState.equippedAccessoryID = id
            cat.lastInteractionMessage = "新配饰戴好了，走路都更神气。"
        }
        transientNotice = "配饰已经戴上。"
    }

    func purchaseOrPlaceFurniture(_ id: String, in slot: HomeSlot) {
        if !saveState.globalUnlocks.furnitureIDs.contains(id), let furniture = GameContent.furniture(id: id) {
            guard saveState.coins >= furniture.cost else {
                transientNotice = "金币还差一点点。"
                return
            }
            mutateSave { save in
                save.coins -= furniture.cost
                save.globalUnlocks.furnitureIDs.insert(id)
            }
        }

        mutateCurrentCat { cat in
            cat.homeState.placements[slot.rawValue] = id
            cat.lastInteractionMessage = "\(GameContent.furniture(id: id)?.title ?? "家具")已经摆进房间。"
        }
        transientNotice = "房间布置好了。"
    }

    func setWallpaper(_ wallpaper: WallpaperStyle) {
        mutateCurrentCat { cat in
            cat.homeState.wallpaper = wallpaper
        }
    }

    func startTrip(destinationID: String, durationMinutes: Int) {
        refreshTripStates()
        guard let currentCat, currentCat.tripState.status == .idle else {
            transientNotice = "现在已经有一段旅程正在路上。"
            return
        }

        let now = clock.now
        let end = now.addingTimeInterval(Double(durationMinutes) * 60)
        let plan = TripPlan(destinationID: destinationID, durationMinutes: durationMinutes, startedAt: now, endsAt: end)
        let reward = tripResolutionEngine.prepareReward(for: plan, cat: currentCat)

        mutateCurrentCat { cat in
            refreshDailyTasksIfNeeded(for: &cat, now: now)
            cat.tripState = TripState(status: .traveling, currentPlan: plan, pendingReward: reward, lastReturnedAt: cat.tripState.lastReturnedAt)
            cat.dailyTasks.traveledToday = true
            cat.mood = .proud
            let destinationName = GameContent.destination(id: destinationID)?.title ?? "旅行地"
            cat.lastInteractionMessage = "已经出发去\(destinationName)，记得晚点来看它带回了什么。"
        }
        transientNotice = "旅行开始啦。"
    }

    func refreshTripStates() {
        let now = clock.now
        mutateSave { save in
            for index in save.cats.indices {
                refreshDailyTasksIfNeeded(for: &save.cats[index], now: now)
                if let plan = save.cats[index].tripState.currentPlan,
                   save.cats[index].tripState.status == .traveling,
                   now >= plan.endsAt {
                    save.cats[index].tripState.status = .readyToClaim
                    save.cats[index].lastInteractionMessage = "旅行结束啦，快看看它带回了什么。"
                }
            }
        }
    }

    func claimTripReward() {
        refreshTripStates()
        guard let currentCat, currentCat.tripState.status == .readyToClaim,
              let reward = currentCat.tripState.pendingReward else {
            transientNotice = "还没有可领取的旅行收获。"
            return
        }

        let claimedAt = clock.now
        var rewardEngine = RewardEngine()
        var duplicateCoins = 0

        mutateCurrentCat { cat in
            duplicateCoins = rewardEngine.claim(reward, for: &cat, claimedAt: claimedAt)
            cat.tripState = .idle
            cat.tripState.lastReturnedAt = claimedAt
            cat.mood = .relaxed
            cat.intimacy += 5
            cat.lastInteractionMessage = reward.summary
        }

        mutateSave { save in
            save.coins += reward.coins + duplicateCoins
        }
        transientNotice = "旅行收获已领取，获得 \(reward.coins + duplicateCoins) 金币。"
    }

    var currentCatFeedCooldown: TimeInterval {
        cooldownRemaining(from: currentCat?.lastFedAt, cooldown: 45 * 60)
    }

    var currentCatPlayCooldown: TimeInterval {
        cooldownRemaining(from: currentCat?.lastPlayedAt, cooldown: 12 * 60)
    }

    func albumEntry(for id: String, category: AlbumCategory) -> AlbumEntry? {
        currentCat?.albumEntries.first(where: { $0.contentID == id && $0.category == category })
    }

    func isOutfitUnlocked(_ id: String) -> Bool {
        saveState.globalUnlocks.outfitIDs.contains(id)
    }

    func isAccessoryUnlocked(_ id: String) -> Bool {
        saveState.globalUnlocks.accessoryIDs.contains(id)
    }

    func isFurnitureUnlocked(_ id: String) -> Bool {
        saveState.globalUnlocks.furnitureIDs.contains(id)
    }

    private func load() {
        do {
            saveState = try saveStore.load()
        } catch {
            saveState = .empty
            transientNotice = "读取存档失败，已恢复为新的本地档案。"
        }

        if saveState.selectedCatID == nil {
            saveState.selectedCatID = saveState.cats.first?.id
        }

        refreshTripStates()
        isLoaded = true
    }

    private func currentDayKey() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: clock.now)
    }

    private func cooldownRemaining(from lastDate: Date?, cooldown: TimeInterval) -> TimeInterval {
        guard let lastDate else { return 0 }
        return max(0, cooldown - clock.now.timeIntervalSince(lastDate))
    }

    private func refreshDailyTasksIfNeeded(for cat: inout CatProfile, now: Date) {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        let today = formatter.string(from: now)

        if cat.dailyTasks.dayKey != today {
            cat.dailyTasks = .fresh(dayKey: today)
        }
    }

    private func mutateCurrentCat(_ mutate: (inout CatProfile) -> Void) {
        mutateSave { save in
            guard let selectedCatID = save.selectedCatID ?? save.cats.first?.id,
                  let index = save.cats.firstIndex(where: { $0.id == selectedCatID }) else {
                return
            }
            mutate(&save.cats[index])
        }
    }

    private func mutateSave(_ mutate: (inout GameSaveState) -> Void) {
        var snapshot = saveState
        mutate(&snapshot)
        if snapshot.selectedCatID == nil {
            snapshot.selectedCatID = snapshot.cats.first?.id
        }
        saveState = snapshot

        do {
            try saveStore.save(snapshot)
        } catch {
            transientNotice = "存档没有写入成功，不过当前操作还在内存里。"
        }
    }
}
