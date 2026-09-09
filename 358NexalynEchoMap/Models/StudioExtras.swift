import Foundation

enum ThemeSort: String, Codable, CaseIterable, Identifiable {
    case manual
    case name
    case frameCount
    case recent

    var id: String { rawValue }

    var title: String {
        switch self {
        case .manual: return "Manual"
        case .name: return "Name"
        case .frameCount: return "Frames"
        case .recent: return "Recent"
        }
    }
}

struct MoodWall: Identifiable, Codable, Hashable {
    var id: UUID
    var title: String
    var itemIDs: [String]
}

struct DeletedAlbumRecord: Identifiable, Codable, Hashable {
    var album: Album
    var notes: [Note]
    var deletedAt: Date
    var id: UUID { album.id }
}

struct DeletedNoteRecord: Identifiable, Codable, Hashable {
    var note: Note
    var deletedAt: Date
    var id: UUID { note.id }
}

enum UndoKind: String, Codable {
    case album
    case note
}

struct DailyPrompt: Equatable {
    enum Kind: Equatable {
        case still(String)
        case inspiration(String)
    }

    var kind: Kind
    var title: String
    var subtitle: String
    var imageName: String
}
