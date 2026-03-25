import Foundation

protocol CatAvatarGenerationServicing: Sendable {
    func generateSeed(from imageData: Data, apiKey: String, model: String) async throws -> CatAppearanceSeed
}

enum CatAvatarGenerationError: LocalizedError {
    case missingAPIKey
    case invalidResponse
    case invalidJSON
    case unsupportedValue(field: String, value: String)
    case api(message: String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "还没有配置 OpenAI API Key。"
        case .invalidResponse:
            return "AI 返回内容不完整，已经切回手动捏猫。"
        case .invalidJSON:
            return "AI 没有返回可解析的 JSON。"
        case let .unsupportedValue(field, value):
            return "AI 返回了暂不支持的\(field)：\(value)"
        case let .api(message):
            return message
        }
    }
}

struct OpenAICatAvatarGenerationService: CatAvatarGenerationServicing, Sendable {
    func generateSeed(from imageData: Data, apiKey: String, model: String) async throws -> CatAppearanceSeed {
        guard !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CatAvatarGenerationError.missingAPIKey
        }

        let base64 = imageData.base64EncodedString()
        let requestBody = OpenAIResponsesRequest(
            model: model,
            input: [
                .init(
                    role: "developer",
                    content: [
                        .text("""
                        Analyze the uploaded cat photo and return JSON only.
                        Use exactly one enum value for each field.
                        Allowed values:
                        primaryFur / secondaryFur: cream, ginger, cocoa, charcoal, snow, calico
                        pattern: solid, striped, patches, socks, cloudy
                        facePattern: plain, mask, blaze, noseDot
                        eyeColor: jade, amber, sky, coffee
                        earShape: round, pointy, fluffy
                        bodyType: tiny, balanced, chonky
                        tailShape: plume, ringed, curled
                        Keep notes under 40 words.
                        """)
                    ]
                ),
                .init(
                    role: "user",
                    content: [
                        .text("Please extract an editable cat appearance seed from this photo as JSON."),
                        .image("data:image/jpeg;base64,\(base64)")
                    ]
                )
            ],
            text: .init(format: .init(type: "json_object"))
        )

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/responses")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpBody = try JSONEncoder().encode(requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CatAvatarGenerationError.invalidResponse
        }

        if !(200...299).contains(httpResponse.statusCode) {
            let apiError = try? JSONDecoder().decode(OpenAIErrorEnvelope.self, from: data)
            throw CatAvatarGenerationError.api(message: apiError?.error.message ?? "AI 服务暂时没有响应。")
        }

        let envelope = try JSONDecoder().decode(OpenAIResponsesEnvelope.self, from: data)
        let jsonText = envelope.outputText ?? envelope.output.firstText
        guard let jsonText else {
            throw CatAvatarGenerationError.invalidResponse
        }

        let normalized = jsonText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let payloadData = normalized.data(using: .utf8) else {
            throw CatAvatarGenerationError.invalidJSON
        }

        let seedResponse = try JSONDecoder().decode(SeedPayload.self, from: payloadData)
        return try seedResponse.asSeed()
    }
}

private struct OpenAIResponsesRequest: Encodable {
    let model: String
    let input: [Message]
    let text: TextBody

    struct Message: Encodable {
        let role: String
        let content: [Item]
    }

    struct Item: Encodable {
        let type: String
        let text: String?
        let imageURL: String?
        let detail: String?

        enum CodingKeys: String, CodingKey {
            case type
            case text
            case imageURL = "image_url"
            case detail
        }

        static func text(_ value: String) -> Item {
            Item(type: "input_text", text: value, imageURL: nil, detail: nil)
        }

        static func image(_ value: String) -> Item {
            Item(type: "input_image", text: nil, imageURL: value, detail: "auto")
        }
    }

    struct TextBody: Encodable {
        let format: Format
    }

    struct Format: Encodable {
        let type: String
    }
}

private struct OpenAIResponsesEnvelope: Decodable {
    let outputText: String?
    let output: [OutputMessage]

    enum CodingKeys: String, CodingKey {
        case outputText = "output_text"
        case output
    }

    struct OutputMessage: Decodable {
        let content: [Content]

        struct Content: Decodable {
            let text: String?
        }
    }
}

private extension Array where Element == OpenAIResponsesEnvelope.OutputMessage {
    var firstText: String? {
        for message in self {
            for content in message.content {
                if let text = content.text, !text.isEmpty {
                    return text
                }
            }
        }
        return nil
    }
}

private struct OpenAIErrorEnvelope: Decodable {
    let error: OpenAIAPIError

    struct OpenAIAPIError: Decodable {
        let message: String
    }
}

private struct SeedPayload: Decodable {
    let primaryFur: String
    let secondaryFur: String
    let pattern: String
    let facePattern: String
    let eyeColor: String
    let earShape: String
    let bodyType: String
    let tailShape: String
    let notes: String

    func asSeed() throws -> CatAppearanceSeed {
        CatAppearanceSeed(
            primaryFur: try enumValue(FurColorPreset.self, field: "毛色主色", value: primaryFur),
            secondaryFur: try enumValue(FurColorPreset.self, field: "毛色辅色", value: secondaryFur),
            pattern: try enumValue(CatPatternPreset.self, field: "花纹", value: pattern),
            facePattern: try enumValue(FacePatternPreset.self, field: "脸部花纹", value: facePattern),
            eyeColor: try enumValue(EyeColorPreset.self, field: "眼睛颜色", value: eyeColor),
            earShape: try enumValue(EarShapePreset.self, field: "耳朵形状", value: earShape),
            bodyType: try enumValue(BodyTypePreset.self, field: "体型", value: bodyType),
            tailShape: try enumValue(TailShapePreset.self, field: "尾巴", value: tailShape),
            notes: notes
        )
    }

    private func enumValue<T: RawRepresentable>(_ type: T.Type, field: String, value: String) throws -> T where T.RawValue == String {
        guard let enumValue = T(rawValue: value) else {
            throw CatAvatarGenerationError.unsupportedValue(field: field, value: value)
        }
        return enumValue
    }
}
