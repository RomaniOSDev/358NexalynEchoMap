import Foundation
import Combine

final class AlbumDetailViewModel: ObservableObject {
    let albumID: UUID
    @Published var composerPresented = false
    @Published var moveNote: Note?
    @Published var titleDraft = ""
    @Published var emojisDraft = ""
    @Published var coverDraft: String?
    @Published var titleError: String?
    @Published var tagFilter: String?

    init(albumID: UUID) {
        self.albumID = albumID
    }

    func loadDraft(from album: Album) {
        titleDraft = album.title
        emojisDraft = album.emojis
        coverDraft = album.coverImageName
        titleError = nil
    }

    func saveAlbum(store: DataStore) -> Bool {
        let result = TitleValidator.validated(titleDraft)
        if let message = result.error {
            titleError = message
            return false
        }
        guard let title = result.title else { return false }
        titleError = nil
        let emojis = emojisDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        store.updateAlbum(
            id: albumID,
            title: title,
            emojis: emojis.isEmpty ? "🎞️" : emojis,
            coverImageName: coverDraft
        )
        composerPresented = false
        return true
    }

    func destinationAlbums(store: DataStore) -> [Album] {
        store.albums.filter { $0.id != albumID }
    }
}
