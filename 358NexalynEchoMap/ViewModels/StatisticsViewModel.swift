import Foundation
import Combine

struct StatBar: Identifiable, Hashable {
    var id: String { label }
    let label: String
    let value: Int
}

struct StudioStatsSnapshot {
    let themeCount: Int
    let frameCount: Int
    let annotationCount: Int
    let favouriteCount: Int
    let wordCount: Int
    let taggedFrameCount: Int
    let framesByTheme: [StatBar]
    let framesByStill: [StatBar]
    let topTags: [StatBar]
    let annotationCoverage: [StatBar]
    let favouritesByCollection: [StatBar]

    var isEmpty: Bool {
        themeCount + frameCount + annotationCount + favouriteCount == 0
    }
}

final class StatisticsViewModel: ObservableObject {
    func snapshot(from store: DataStore) -> StudioStatsSnapshot {
        let stillCount = BundledStill.allCases.count
        let annotated = min(store.captions.count, stillCount)
        let words = store.notes.reduce(0) { total, note in
            total + note.content.split { $0.isWhitespace || $0.isNewline }.count
        }

        var tagCounts: [String: Int] = [:]
        for tag in store.notes.flatMap(\.tags) {
            let key = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !key.isEmpty else { continue }
            tagCounts[key, default: 0] += 1
        }

        var stillCounts: [String: Int] = [:]
        for still in BundledStill.allCases {
            stillCounts[still.rawValue] = 0
        }
        for note in store.notes {
            stillCounts[note.imageName, default: 0] += 1
        }

        var collectionCounts: [String: Int] = [:]
        for collection in InspirationCatalog.collections {
            collectionCounts[collection] = 0
        }
        for item in InspirationCatalog.items where store.isFavorite(item.id) {
            collectionCounts[item.collection, default: 0] += 1
        }

        return StudioStatsSnapshot(
            themeCount: store.albums.count,
            frameCount: store.notes.count,
            annotationCount: store.captions.count,
            favouriteCount: store.favoriteIDs.count,
            wordCount: words,
            taggedFrameCount: store.notes.filter { !$0.tags.isEmpty }.count,
            framesByTheme: store.albums.map { album in
                StatBar(label: album.title, value: store.notes(in: album.id).count)
            },
            framesByStill: BundledStill.allCases.map { still in
                StatBar(label: still.displayTitle, value: stillCounts[still.rawValue] ?? 0)
            },
            topTags: tagCounts
                .map { StatBar(label: $0.key, value: $0.value) }
                .sorted { $0.value > $1.value }
                .prefix(8)
                .map { $0 },
            annotationCoverage: [
                StatBar(label: "Captioned", value: annotated),
                StatBar(label: "Open", value: max(0, stillCount - annotated))
            ],
            favouritesByCollection: InspirationCatalog.collections.map { collection in
                StatBar(label: collection, value: collectionCounts[collection] ?? 0)
            }
        )
    }
}
