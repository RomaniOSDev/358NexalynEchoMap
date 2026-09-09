import Foundation
import Combine

final class StudioViewModel: ObservableObject {
    @Published var selectedAlbumID: UUID?
    @Published var composerPresented = false
    @Published var titleDraft = ""
    @Published var emojisDraft = "🎞️"
    @Published var coverDraft: String?
    @Published var titleError: String?
    @Published var tagFilter: String?

    func openComposer() {
        titleDraft = ""
        emojisDraft = "🎞️"
        coverDraft = nil
        titleError = nil
        composerPresented = true
    }

    func createAlbum(store: DataStore) -> Album? {
        let result = TitleValidator.validated(titleDraft)
        if let message = result.error {
            titleError = message
            return nil
        }
        guard let title = result.title else { return nil }
        titleError = nil
        let emojis = emojisDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        let album = store.addAlbum(
            title: title,
            emojis: emojis.isEmpty ? "🎞️" : emojis,
            coverImageName: coverDraft
        )
        selectedAlbumID = album.id
        composerPresented = false
        return album
    }
}
