import Foundation

struct Album: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var emojis: String
    var coverImageName: String?
    var sortIndex: Int
    var updatedAt: Date

    init(
        id: UUID,
        title: String,
        emojis: String,
        coverImageName: String? = nil,
        sortIndex: Int = 0,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.emojis = emojis
        self.coverImageName = coverImageName
        self.sortIndex = sortIndex
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        title = try c.decode(String.self, forKey: .title)
        emojis = try c.decode(String.self, forKey: .emojis)
        coverImageName = try c.decodeIfPresent(String.self, forKey: .coverImageName)
        sortIndex = try c.decodeIfPresent(Int.self, forKey: .sortIndex) ?? 0
        updatedAt = try c.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
    }
}
