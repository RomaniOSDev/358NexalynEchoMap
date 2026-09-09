import Foundation

struct NotePrefill: Hashable {
    var imageName: String?
    var tags: [String]
    var content: String
}

struct NoteDraftTarget: Hashable {
    var noteID: UUID?
    var albumID: UUID
    var prefills: NotePrefill?
}

enum AppRoute: Hashable {
    case album(UUID)
    case noteEditor(NoteDraftTarget)
    case annotations
    case annotationEditor(String)
    case inspirations
    case inspiration(String)
    case statistics
    case settings
    case search
    case tagManager
    case compare
    case focusTimer
    case recentlyDeleted
}
