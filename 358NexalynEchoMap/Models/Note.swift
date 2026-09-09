import Foundation

struct Note: Identifiable, Codable, Hashable {
    var id: UUID
    var albumID: UUID
    var content: String
    var tags: [String]
    var imageName: String
    var updatedAt: Date

    init(
        id: UUID,
        albumID: UUID,
        content: String,
        tags: [String],
        imageName: String,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.albumID = albumID
        self.content = content
        self.tags = tags
        self.imageName = imageName
        self.updatedAt = updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(UUID.self, forKey: .id)
        albumID = try c.decode(UUID.self, forKey: .albumID)
        content = try c.decode(String.self, forKey: .content)
        tags = try c.decode([String].self, forKey: .tags)
        imageName = try c.decode(String.self, forKey: .imageName)
        updatedAt = try c.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
    }
}
