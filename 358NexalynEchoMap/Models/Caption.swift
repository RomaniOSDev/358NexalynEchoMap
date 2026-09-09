import Foundation

struct InkPoint: Codable, Hashable {
    var x: Double
    var y: Double
}

struct InkStroke: Identifiable, Codable, Hashable {
    var id: UUID
    var points: [InkPoint]
    var isMarker: Bool

    init(id: UUID = UUID(), points: [InkPoint], isMarker: Bool) {
        self.id = id
        self.points = points
        self.isMarker = isMarker
    }
}

struct Caption: Identifiable, Codable, Hashable {
    var imageId: String
    var text: String
    var timestamp: Date
    var strokes: [InkStroke]

    var id: String { imageId }

    init(imageId: String, text: String, timestamp: Date, strokes: [InkStroke] = []) {
        self.imageId = imageId
        self.text = text
        self.timestamp = timestamp
        self.strokes = strokes
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        imageId = try c.decode(String.self, forKey: .imageId)
        text = try c.decode(String.self, forKey: .text)
        timestamp = try c.decode(Date.self, forKey: .timestamp)
        strokes = try c.decodeIfPresent([InkStroke].self, forKey: .strokes) ?? []
    }
}
