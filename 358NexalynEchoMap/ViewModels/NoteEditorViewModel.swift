import Foundation
import Combine

final class NoteEditorViewModel: ObservableObject {
    @Published var content = ""
    @Published var tagDraft = ""
    @Published var tags: [String] = []
    @Published var imageName = BundledStill.sculpture.rawValue
    @Published var error: String?
    @Published private var didLoad = false

    let noteID: UUID?
    let albumID: UUID
    let prefills: NotePrefill?

    init(config: NoteDraftTarget) {
        noteID = config.noteID
        albumID = config.albumID
        prefills = config.prefills
    }

    func load(from store: DataStore) {
        guard !didLoad else { return }
        didLoad = true
        if let noteID, let note = store.note(id: noteID) {
            content = note.content
            tags = note.tags
            imageName = note.imageName
            return
        }
        if let prefills {
            if let name = prefills.imageName {
                imageName = name
            }
            tags = prefills.tags
            content = prefills.content
        }
    }

    func addTag() {
        let tag = tagDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tag.isEmpty else { return }
        if !tags.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) {
            tags.append(tag)
        }
        tagDraft = ""
    }

    func applySuggested(_ tag: String) {
        if !tags.contains(where: { $0.caseInsensitiveCompare(tag) == .orderedSame }) {
            tags.append(tag)
        }
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    func save(store: DataStore) -> Bool {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            error = "Write a note for this frame"
            return false
        }
        error = nil
        if let noteID {
            store.updateNote(id: noteID, content: trimmed, tags: tags, imageName: imageName)
        } else {
            store.addNote(albumID: albumID, content: trimmed, tags: tags, imageName: imageName)
        }
        return true
    }
}
