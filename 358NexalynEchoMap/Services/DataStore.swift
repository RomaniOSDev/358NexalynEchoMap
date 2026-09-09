import Foundation
import Combine

final class DataStore: ObservableObject {
    @Published private(set) var albums: [Album] = []
    @Published private(set) var notes: [Note] = []
    @Published private(set) var captions: [Caption] = []
    @Published private(set) var favoriteIDs: Set<String> = []
    @Published private(set) var moodWalls: [MoodWall] = []
    @Published private(set) var deletedAlbums: [DeletedAlbumRecord] = []
    @Published private(set) var deletedNotes: [DeletedNoteRecord] = []
    @Published private(set) var themeSort: ThemeSort = .manual
    @Published private(set) var undoBanner: String?
    @Published private(set) var lastUndo: UndoKind?

    private let defaults = UserDefaults.standard
    private let storageKey = "studio.snapshot.v1"
    private let trashLimit = 20

    private var dailyKey: String?
    private var dailyStillName: String?
    private var dailyInspirationID: String?

    init() {
        hydrate()
    }

    func album(id: UUID) -> Album? {
        albums.first { $0.id == id }
    }

    func note(id: UUID) -> Note? {
        notes.first { $0.id == id }
    }

    func notes(in albumID: UUID) -> [Note] {
        notes.filter { $0.albumID == albumID }
    }

    func caption(for imageId: String) -> Caption? {
        captions.first { $0.imageId == imageId }
    }

    func captionSubtitle(for imageId: String) -> String {
        guard let caption = caption(for: imageId) else { return "Tap to annotate" }
        let trimmed = caption.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        if !caption.strokes.isEmpty { return "Sketch" }
        return "Tap to annotate"
    }

    func coverImage(for album: Album) -> String {
        if let name = album.coverImageName, !name.isEmpty {
            return name
        }
        if let name = notes(in: album.id).first?.imageName {
            return name
        }
        let stills = BundledStill.allCases
        let seed = album.id.uuidString.utf8.reduce(0) { $0 &+ Int($1) }
        let idx = seed % stills.count
        return stills[idx].rawValue
    }

    func sortedAlbums() -> [Album] {
        switch themeSort {
        case .manual:
            return albums.sorted { $0.sortIndex < $1.sortIndex }
        case .name:
            return albums.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .frameCount:
            return albums.sorted { notes(in: $0.id).count > notes(in: $1.id).count }
        case .recent:
            return albums.sorted { $0.updatedAt > $1.updatedAt }
        }
    }

    func setThemeSort(_ sort: ThemeSort) {
        themeSort = sort
        persist()
    }

    func allNoteTags() -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for tag in notes.flatMap(\.tags) {
            let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let key = trimmed.lowercased()
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            result.append(trimmed)
        }
        return result.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
    }

    func tagCounts() -> [(tag: String, count: Int)] {
        var counts: [String: (name: String, count: Int)] = [:]
        for tag in notes.flatMap(\.tags) {
            let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let key = trimmed.lowercased()
            if let existing = counts[key] {
                counts[key] = (existing.name, existing.count + 1)
            } else {
                counts[key] = (trimmed, 1)
            }
        }
        return counts.values
            .map { (tag: $0.name, count: $0.count) }
            .sorted { $0.count > $1.count }
    }

    func notesMatching(tag: String?) -> [Note] {
        guard let tag, !tag.isEmpty else { return notes }
        return notes.filter { note in
            note.tags.contains { $0.caseInsensitiveCompare(tag) == .orderedSame }
        }
    }

    func notes(in albumID: UUID, tag: String?) -> [Note] {
        let frames = notes(in: albumID)
        guard let tag, !tag.isEmpty else { return frames }
        return frames.filter { note in
            note.tags.contains { $0.caseInsensitiveCompare(tag) == .orderedSame }
        }
    }

    @discardableResult
    func addAlbum(title: String, emojis: String, coverImageName: String? = nil) -> Album {
        let nextIndex = (albums.map(\.sortIndex).max() ?? -1) + 1
        let album = Album(
            id: UUID(),
            title: title,
            emojis: emojis,
            coverImageName: coverImageName,
            sortIndex: nextIndex
        )
        albums.append(album)
        persist()
        return album
    }

    func updateAlbum(id: UUID, title: String, emojis: String, coverImageName: String?) {
        guard let index = albums.firstIndex(where: { $0.id == id }) else { return }
        albums[index].title = title
        albums[index].emojis = emojis
        albums[index].coverImageName = coverImageName
        albums[index].updatedAt = Date()
        persist()
    }

    func deleteAlbum(id: UUID) {
        guard let album = album(id: id) else { return }
        let captured = notes.filter { $0.albumID == id }
        deletedAlbums.append(DeletedAlbumRecord(album: album, notes: captured, deletedAt: Date()))
        pruneTrash()
        albums.removeAll { $0.id == id }
        notes.removeAll { $0.albumID == id }
        lastUndo = .album
        undoBanner = "Theme removed"
        persist()
    }

    func moveAlbum(id: UUID, offset: Int) {
        let ordered = albums.sorted { $0.sortIndex < $1.sortIndex }
        guard let from = ordered.firstIndex(where: { $0.id == id }) else { return }
        let to = from + offset
        guard ordered.indices.contains(to) else { return }
        var next = ordered
        next.swapAt(from, to)
        applyManualOrder(next)
    }

    func reorderAlbum(_ sourceID: UUID, onto targetID: UUID) {
        guard sourceID != targetID else { return }
        var ordered = albums.sorted { $0.sortIndex < $1.sortIndex }
        guard let from = ordered.firstIndex(where: { $0.id == sourceID }) else { return }
        let item = ordered.remove(at: from)
        let dest = ordered.firstIndex(where: { $0.id == targetID }) ?? ordered.endIndex
        ordered.insert(item, at: dest)
        applyManualOrder(ordered)
    }

    @discardableResult
    func addNote(albumID: UUID, content: String, tags: [String], imageName: String) -> Note {
        let note = Note(id: UUID(), albumID: albumID, content: content, tags: uniquedTags(tags), imageName: imageName)
        notes.insert(note, at: 0)
        touchAlbum(albumID)
        persist()
        return note
    }

    func updateNote(id: UUID, content: String, tags: [String], imageName: String) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        notes[index].content = content
        notes[index].tags = uniquedTags(tags)
        notes[index].imageName = imageName
        notes[index].updatedAt = Date()
        touchAlbum(notes[index].albumID)
        persist()
    }

    func deleteNote(id: UUID) {
        guard let note = note(id: id) else { return }
        deletedNotes.append(DeletedNoteRecord(note: note, deletedAt: Date()))
        pruneTrash()
        notes.removeAll { $0.id == id }
        touchAlbum(note.albumID)
        lastUndo = .note
        undoBanner = "Frame removed"
        persist()
    }

    @discardableResult
    func duplicateNote(id: UUID) -> Note? {
        guard let note = note(id: id) else { return nil }
        return addNote(albumID: note.albumID, content: note.content, tags: note.tags, imageName: note.imageName)
    }

    func moveNote(id: UUID, to albumID: UUID) {
        guard let index = notes.firstIndex(where: { $0.id == id }) else { return }
        let previous = notes[index].albumID
        notes[index].albumID = albumID
        notes[index].updatedAt = Date()
        touchAlbum(previous)
        touchAlbum(albumID)
        persist()
    }

    func upsertCaption(imageId: String, text: String, strokes: [InkStroke]) {
        let caption = Caption(imageId: imageId, text: text, timestamp: Date(), strokes: strokes)
        if let index = captions.firstIndex(where: { $0.imageId == imageId }) {
            captions[index] = caption
        } else {
            captions.append(caption)
        }
        persist()
    }

    func deleteCaption(imageId: String) {
        captions.removeAll { $0.imageId == imageId }
        persist()
    }

    func isFavorite(_ inspirationID: String) -> Bool {
        favoriteIDs.contains(inspirationID)
    }

    func toggleFavorite(_ inspirationID: String) {
        if favoriteIDs.contains(inspirationID) {
            favoriteIDs.remove(inspirationID)
        } else {
            favoriteIDs.insert(inspirationID)
        }
        persist()
    }

    func suggestedTags() -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        func append(_ raw: String) {
            let tag = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !tag.isEmpty else { return }
            let key = tag.lowercased()
            guard !seen.contains(key) else { return }
            seen.insert(key)
            result.append(tag)
        }
        albums.forEach { append($0.title) }
        notes.flatMap(\.tags).forEach(append)
        InspirationCatalog.collections.forEach(append)
        return result
    }

    func relatedInspirations(for album: Album) -> [Inspiration] {
        let tags = albumTags(for: album)
        return InspirationCatalog.items.filter { item in
            guard favoriteIDs.contains(item.id) else { return false }
            return item.tags.contains { tags.contains($0.lowercased()) }
                || tags.contains(item.collection.lowercased())
        }
    }

    func relatedNotes(for album: Album) -> [Note] {
        let tags = albumTags(for: album)
        guard !tags.isEmpty else { return [] }
        return notes.filter { note in
            note.albumID != album.id && note.tags.contains { tags.contains($0.lowercased()) }
        }
    }

    func renameTag(from: String, to: String) -> String? {
        let destination = to.trimmingCharacters(in: .whitespacesAndNewlines)
        if destination.isEmpty { return "Give this tag a name" }
        if destination.count > 32 { return "Keep the tag under 32 characters" }
        for index in notes.indices {
            notes[index].tags = uniquedTags(notes[index].tags.map { tag in
                tag.caseInsensitiveCompare(from) == .orderedSame ? destination : tag
            })
            notes[index].updatedAt = Date()
        }
        persist()
        return nil
    }

    func deleteTag(_ tag: String) {
        for index in notes.indices {
            notes[index].tags.removeAll { $0.caseInsensitiveCompare(tag) == .orderedSame }
            notes[index].updatedAt = Date()
        }
        persist()
    }

    func mergeTag(from: String, into: String) -> String? {
        guard from.caseInsensitiveCompare(into) != .orderedSame else {
            return "Pick a different tag to merge into"
        }
        return renameTag(from: from, to: into)
    }

    @discardableResult
    func addMoodWall(title: String) -> MoodWall? {
        let result = TitleValidator.validated(title)
        guard let name = result.title else { return nil }
        let wall = MoodWall(id: UUID(), title: name, itemIDs: [])
        moodWalls.append(wall)
        persist()
        return wall
    }

    func renameMoodWall(id: UUID, title: String) -> String? {
        let result = TitleValidator.validated(title)
        if let message = result.error { return message }
        guard let name = result.title else { return "Give this wall a title" }
        guard let index = moodWalls.firstIndex(where: { $0.id == id }) else { return nil }
        moodWalls[index].title = name
        persist()
        return nil
    }

    func deleteMoodWall(id: UUID) {
        moodWalls.removeAll { $0.id == id }
        persist()
    }

    func toggleMoodWallItem(wallID: UUID, itemID: String) {
        guard let index = moodWalls.firstIndex(where: { $0.id == wallID }) else { return }
        if let existing = moodWalls[index].itemIDs.firstIndex(of: itemID) {
            moodWalls[index].itemIDs.remove(at: existing)
        } else {
            moodWalls[index].itemIDs.append(itemID)
        }
        persist()
    }

    func moodWall(id: UUID) -> MoodWall? {
        moodWalls.first { $0.id == id }
    }

    func isInMoodWall(wallID: UUID, itemID: String) -> Bool {
        moodWall(id: wallID)?.itemIDs.contains(itemID) == true
    }

    func dailyPrompt() -> DailyPrompt {
        let key = Self.dayKey(Date())
        if dailyKey == key {
            return materializedDaily()
        }
        return computedDaily(for: key)
    }

    func refreshDailyIfNeeded() {
        let key = Self.dayKey(Date())
        if dailyKey == key { return }
        let prompt = computedDaily(for: key)
        dailyKey = key
        switch prompt.kind {
        case .still(let name):
            dailyStillName = name
            dailyInspirationID = nil
        case .inspiration(let id):
            dailyStillName = nil
            dailyInspirationID = id
        }
        persist()
    }

    func undoLast() {
        switch lastUndo {
        case .album:
            if let record = deletedAlbums.popLast() {
                restoreAlbumRecord(record)
            }
        case .note:
            guard let record = deletedNotes.last else { break }
            if albums.contains(where: { $0.id == record.note.albumID }) {
                deletedNotes.removeLast()
                restoreNoteRecord(record)
            } else {
                undoBanner = "Restore the theme first"
                persist()
                return
            }
        case .none:
            break
        }
        lastUndo = nil
        undoBanner = nil
        persist()
    }

    func dismissUndoBanner() {
        undoBanner = nil
    }

    func restoreDeletedAlbum(id: UUID) {
        guard let index = deletedAlbums.firstIndex(where: { $0.id == id }) else { return }
        let record = deletedAlbums.remove(at: index)
        restoreAlbumRecord(record)
        if lastUndo == .album { lastUndo = nil; undoBanner = nil }
        persist()
    }

    func restoreDeletedNote(id: UUID) {
        guard let index = deletedNotes.firstIndex(where: { $0.id == id }) else { return }
        let record = deletedNotes[index]
        guard albums.contains(where: { $0.id == record.note.albumID }) else { return }
        deletedNotes.remove(at: index)
        restoreNoteRecord(record)
        if lastUndo == .note { lastUndo = nil; undoBanner = nil }
        persist()
    }

    func resetAll() {
        albums = []
        notes = []
        captions = []
        favoriteIDs = []
        moodWalls = []
        deletedAlbums = []
        deletedNotes = []
        themeSort = .manual
        undoBanner = nil
        lastUndo = nil
        dailyKey = nil
        dailyStillName = nil
        dailyInspirationID = nil
        persist()
    }

    private func restoreAlbumRecord(_ record: DeletedAlbumRecord) {
        var album = record.album
        album.sortIndex = (albums.map(\.sortIndex).max() ?? -1) + 1
        albums.append(album)
        for note in record.notes where !notes.contains(where: { $0.id == note.id }) {
            notes.append(note)
        }
    }

    private func restoreNoteRecord(_ record: DeletedNoteRecord) {
        guard albums.contains(where: { $0.id == record.note.albumID }) else { return }
        guard !notes.contains(where: { $0.id == record.note.id }) else { return }
        notes.insert(record.note, at: 0)
        touchAlbum(record.note.albumID)
    }

    private func applyManualOrder(_ ordered: [Album]) {
        for (index, album) in ordered.enumerated() {
            if let current = albums.firstIndex(where: { $0.id == album.id }) {
                albums[current].sortIndex = index
            }
        }
        themeSort = .manual
        persist()
    }

    private func touchAlbum(_ id: UUID) {
        guard let index = albums.firstIndex(where: { $0.id == id }) else { return }
        albums[index].updatedAt = Date()
    }

    private func albumTags(for album: Album) -> Set<String> {
        var tags = Set(notes(in: album.id).flatMap { $0.tags.map { $0.lowercased() } })
        album.title
            .lowercased()
            .split { !$0.isLetter && !$0.isNumber }
            .map(String.init)
            .filter { $0.count > 2 }
            .forEach { tags.insert($0) }
        return tags
    }

    private func uniquedTags(_ tags: [String]) -> [String] {
        var seen = Set<String>()
        var result: [String] = []
        for tag in tags {
            let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }
            let key = trimmed.lowercased()
            guard !seen.contains(key) else { continue }
            seen.insert(key)
            result.append(trimmed)
        }
        return result
    }

    private func pruneTrash() {
        if deletedAlbums.count > trashLimit {
            deletedAlbums.removeFirst(deletedAlbums.count - trashLimit)
        }
        if deletedNotes.count > trashLimit {
            deletedNotes.removeFirst(deletedNotes.count - trashLimit)
        }
    }

    private func materializedDaily() -> DailyPrompt {
        if let stillName = dailyStillName, let still = BundledStill(rawValue: stillName) {
            return DailyPrompt(
                kind: .still(still.rawValue),
                title: "Today's still",
                subtitle: "Caption \(still.displayTitle)",
                imageName: still.rawValue
            )
        }
        if let inspirationID = dailyInspirationID,
           let item = InspirationCatalog.items.first(where: { $0.id == inspirationID }) {
            return DailyPrompt(
                kind: .inspiration(item.id),
                title: "Today's still",
                subtitle: item.title,
                imageName: item.imageName
            )
        }
        return computedDaily(for: dailyKey ?? Self.dayKey(Date()))
    }

    private func computedDaily(for key: String) -> DailyPrompt {
        let open = BundledStill.allCases.filter { caption(for: $0.rawValue) == nil }
        if !open.isEmpty {
            let idx = abs(key.utf8.reduce(0) { ($0 &* 31) &+ Int($1) }) % open.count
            let still = open[idx]
            return DailyPrompt(
                kind: .still(still.rawValue),
                title: "Today's still",
                subtitle: "Caption \(still.displayTitle)",
                imageName: still.rawValue
            )
        }
        if !InspirationCatalog.items.isEmpty {
            let idx = abs(key.utf8.reduce(0) { ($0 &* 31) &+ Int($1) }) % InspirationCatalog.items.count
            let item = InspirationCatalog.items[idx]
            return DailyPrompt(
                kind: .inspiration(item.id),
                title: "Today's still",
                subtitle: item.title,
                imageName: item.imageName
            )
        }
        let fallback = BundledStill.palette
        return DailyPrompt(
            kind: .still(fallback.rawValue),
            title: "Today's still",
            subtitle: fallback.displayTitle,
            imageName: fallback.rawValue
        )
    }

    private static func dayKey(_ date: Date) -> String {
        let comps = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(comps.year ?? 0)-\(comps.month ?? 0)-\(comps.day ?? 0)"
    }

    private func hydrate() {
        guard let data = defaults.data(forKey: storageKey) else { return }
        guard let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else { return }
        albums = snapshot.albums
        notes = snapshot.notes
        captions = snapshot.captions
        favoriteIDs = Set(snapshot.favoriteIDs)
        moodWalls = snapshot.moodWalls
        deletedAlbums = snapshot.deletedAlbums
        deletedNotes = snapshot.deletedNotes
        themeSort = snapshot.themeSort
        lastUndo = snapshot.lastUndo
        undoBanner = snapshot.undoBanner
        dailyKey = snapshot.dailyKey
        dailyStillName = snapshot.dailyStillName
        dailyInspirationID = snapshot.dailyInspirationID
        if albums.map(\.sortIndex).allSatisfy({ $0 == 0 }) {
            for index in albums.indices {
                albums[index].sortIndex = index
            }
        }
    }

    private func persist() {
        let snapshot = Snapshot(
            albums: albums,
            notes: notes,
            captions: captions,
            favoriteIDs: Array(favoriteIDs),
            moodWalls: moodWalls,
            deletedAlbums: deletedAlbums,
            deletedNotes: deletedNotes,
            themeSort: themeSort,
            lastUndo: lastUndo,
            undoBanner: undoBanner,
            dailyKey: dailyKey,
            dailyStillName: dailyStillName,
            dailyInspirationID: dailyInspirationID
        )
        if let data = try? JSONEncoder().encode(snapshot) {
            defaults.set(data, forKey: storageKey)
        }
    }
}

private struct Snapshot: Codable {
    var albums: [Album]
    var notes: [Note]
    var captions: [Caption]
    var favoriteIDs: [String]
    var moodWalls: [MoodWall]
    var deletedAlbums: [DeletedAlbumRecord]
    var deletedNotes: [DeletedNoteRecord]
    var themeSort: ThemeSort
    var lastUndo: UndoKind?
    var undoBanner: String?
    var dailyKey: String?
    var dailyStillName: String?
    var dailyInspirationID: String?

    init(
        albums: [Album],
        notes: [Note],
        captions: [Caption],
        favoriteIDs: [String],
        moodWalls: [MoodWall],
        deletedAlbums: [DeletedAlbumRecord],
        deletedNotes: [DeletedNoteRecord],
        themeSort: ThemeSort,
        lastUndo: UndoKind?,
        undoBanner: String?,
        dailyKey: String?,
        dailyStillName: String?,
        dailyInspirationID: String?
    ) {
        self.albums = albums
        self.notes = notes
        self.captions = captions
        self.favoriteIDs = favoriteIDs
        self.moodWalls = moodWalls
        self.deletedAlbums = deletedAlbums
        self.deletedNotes = deletedNotes
        self.themeSort = themeSort
        self.lastUndo = lastUndo
        self.undoBanner = undoBanner
        self.dailyKey = dailyKey
        self.dailyStillName = dailyStillName
        self.dailyInspirationID = dailyInspirationID
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        albums = try c.decode([Album].self, forKey: .albums)
        notes = try c.decode([Note].self, forKey: .notes)
        captions = try c.decode([Caption].self, forKey: .captions)
        favoriteIDs = try c.decode([String].self, forKey: .favoriteIDs)
        moodWalls = try c.decodeIfPresent([MoodWall].self, forKey: .moodWalls) ?? []
        deletedAlbums = try c.decodeIfPresent([DeletedAlbumRecord].self, forKey: .deletedAlbums) ?? []
        deletedNotes = try c.decodeIfPresent([DeletedNoteRecord].self, forKey: .deletedNotes) ?? []
        themeSort = try c.decodeIfPresent(ThemeSort.self, forKey: .themeSort) ?? .manual
        lastUndo = try c.decodeIfPresent(UndoKind.self, forKey: .lastUndo)
        undoBanner = try c.decodeIfPresent(String.self, forKey: .undoBanner)
        dailyKey = try c.decodeIfPresent(String.self, forKey: .dailyKey)
        dailyStillName = try c.decodeIfPresent(String.self, forKey: .dailyStillName)
        dailyInspirationID = try c.decodeIfPresent(String.self, forKey: .dailyInspirationID)
    }
}
