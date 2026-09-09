import SwiftUI

struct StudioSearchView: View {
    @EnvironmentObject private var store: DataStore
    @Binding var path: NavigationPath
    @State private var query = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BrushSectionTitle(title: "Search")
                TextField("Themes, frames, tags, stills", text: $query)
                    .foregroundColor(Color("AppTextPrimary"))
                    .padding(14)
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                if hits.isEmpty {
                    EmptyStateCard(
                        systemImage: "magnifyingglass",
                        message: query.isEmpty ? "Start typing to search the studio" : "Nothing matches that search"
                    )
                } else {
                    ForEach(hits) { hit in
                        Button {
                            open(hit)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(hit.kindLabel)
                                    .font(.caption)
                                    .foregroundColor(Color("AppPrimary"))
                                Text(hit.title)
                                    .font(.system(.headline, design: .serif).italic())
                                    .foregroundColor(Color("AppTextPrimary"))
                                Text(hit.subtitle)
                                    .font(.caption)
                                    .foregroundColor(Color("AppTextSecondary"))
                                    .lineLimit(2)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(14)
                            .background(Color("AppSurface"))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(20)
        }
        .studioCanvas()
        .scrollDismissesKeyboard(.immediately)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Search")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private var hits: [SearchHit] {
        let needle = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !needle.isEmpty else { return [] }
        var result: [SearchHit] = []
        for album in store.sortedAlbums() where album.title.lowercased().contains(needle) {
            result.append(SearchHit(
                id: "album-\(album.id)",
                kindLabel: "Theme",
                title: album.title,
                subtitle: "\(store.notes(in: album.id).count) frames",
                route: .album(album.id)
            ))
        }
        for note in store.notes {
            let hay = ([note.content] + note.tags).joined(separator: " ").lowercased()
            if hay.contains(needle) {
                result.append(SearchHit(
                    id: "note-\(note.id)",
                    kindLabel: "Frame",
                    title: note.content,
                    subtitle: store.album(id: note.albumID)?.title ?? "Theme",
                    route: .noteEditor(NoteDraftTarget(noteID: note.id, albumID: note.albumID))
                ))
            }
        }
        for caption in store.captions where caption.text.lowercased().contains(needle) {
            result.append(SearchHit(
                id: "caption-\(caption.imageId)",
                kindLabel: "Caption",
                title: caption.text,
                subtitle: BundledStill(rawValue: caption.imageId)?.displayTitle ?? "Still",
                route: .annotationEditor(caption.imageId)
            ))
        }
        for tag in store.allNoteTags() where tag.lowercased().contains(needle) {
            result.append(SearchHit(
                id: "tag-\(tag)",
                kindLabel: "Tag",
                title: tag,
                subtitle: "Open tag manager",
                route: .tagManager
            ))
        }
        for item in InspirationCatalog.items {
            let hay = ([item.title, item.collection, item.summary] + item.tags).joined(separator: " ").lowercased()
            if hay.contains(needle) {
                result.append(SearchHit(
                    id: "insp-\(item.id)",
                    kindLabel: "Inspiration",
                    title: item.title,
                    subtitle: item.collection,
                    route: .inspiration(item.id)
                ))
            }
        }
        return result
    }

    private func open(_ hit: SearchHit) {
        path.append(hit.route)
    }
}

private struct SearchHit: Identifiable {
    let id: String
    let kindLabel: String
    let title: String
    let subtitle: String
    let route: AppRoute
}
