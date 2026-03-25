import Foundation

struct SaveStore {
    private let fileManager: FileManager
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        self.encoder = encoder

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder
    }

    func load() throws -> GameSaveState {
        guard fileManager.fileExists(atPath: saveFileURL.path) else {
            return .empty
        }

        let data = try Data(contentsOf: saveFileURL)
        return try decoder.decode(GameSaveState.self, from: data)
    }

    func save(_ state: GameSaveState) throws {
        try ensureDirectories()
        let data = try encoder.encode(state)
        try data.write(to: saveFileURL, options: .atomic)
    }

    func saveReferencePhoto(data: Data, catID: UUID) throws -> String {
        try ensureDirectories()
        let filename = "cat-\(catID.uuidString.lowercased()).jpg"
        let url = photosDirectoryURL.appendingPathComponent(filename)
        try data.write(to: url, options: .atomic)
        return filename
    }

    func loadReferencePhotoData(named filename: String) -> Data? {
        let url = photosDirectoryURL.appendingPathComponent(filename)
        return try? Data(contentsOf: url)
    }

    private var appDirectoryURL: URL {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        return baseURL.appendingPathComponent("BabeGame", isDirectory: true)
    }

    private var saveFileURL: URL {
        appDirectoryURL.appendingPathComponent("save-state.json")
    }

    private var photosDirectoryURL: URL {
        appDirectoryURL.appendingPathComponent("CatPhotos", isDirectory: true)
    }

    private func ensureDirectories() throws {
        try fileManager.createDirectory(at: appDirectoryURL, withIntermediateDirectories: true, attributes: nil)
        try fileManager.createDirectory(at: photosDirectoryURL, withIntermediateDirectories: true, attributes: nil)
    }
}
