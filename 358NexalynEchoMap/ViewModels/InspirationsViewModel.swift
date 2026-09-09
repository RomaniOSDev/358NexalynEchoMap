import Foundation
import Combine

final class InspirationsViewModel: ObservableObject {
    enum Shelf: Hashable {
        case all
        case catalog(String)
        case wall(UUID)
    }

    @Published var query = ""
    @Published var shelf: Shelf = .all
    @Published var wallTitleDraft = ""
    @Published var wallComposerPresented = false
    @Published var wallError: String?

    func visibleItems(store: DataStore) -> [Inspiration] {
        var items = InspirationCatalog.items
        switch shelf {
        case .all:
            break
        case .catalog(let name):
            items = items.filter { $0.collection == name }
        case .wall(let id):
            let ids = Set(store.moodWall(id: id)?.itemIDs ?? [])
            items = items.filter { ids.contains($0.id) }
        }
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return items }
        return items.filter { item in
            item.title.lowercased().contains(needle)
                || item.collection.lowercased().contains(needle)
                || item.summary.lowercased().contains(needle)
                || item.tags.contains { $0.lowercased().contains(needle) }
        }
    }

    func openWallComposer() {
        wallTitleDraft = ""
        wallError = nil
        wallComposerPresented = true
    }

    func createWall(store: DataStore) {
        if let wall = store.addMoodWall(title: wallTitleDraft) {
            wallError = nil
            wallComposerPresented = false
            shelf = .wall(wall.id)
        } else {
            wallError = TitleValidator.validated(wallTitleDraft).error
        }
    }
}
