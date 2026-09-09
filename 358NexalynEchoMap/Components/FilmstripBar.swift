import SwiftUI

struct FilmstripBar: View {
    let albums: [Album]
    var selectedID: UUID?
    let coverImage: (Album) -> String
    let onSelect: (Album) -> Void
    let onAdd: () -> Void
    var onDelete: ((Album) -> Void)?
    var onMove: ((Album, Int) -> Void)?
    var onReorder: ((UUID, UUID) -> Void)?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(albums) { album in
                    Button {
                        onSelect(album)
                    } label: {
                        SprocketPoster(
                            imageName: coverImage(album),
                            title: album.title,
                            emojis: album.emojis,
                            isSelected: album.id == selectedID
                        )
                    }
                    .buttonStyle(.plain)
                    .draggable(album.id.uuidString)
                    .dropDestination(for: String.self) { items, _ in
                        guard let raw = items.first, let source = UUID(uuidString: raw) else { return false }
                        onReorder?(source, album.id)
                        return true
                    }
                    .contextMenu {
                        Button {
                            onSelect(album)
                        } label: {
                            Label("Open reel", systemImage: "film")
                        }
                        if onMove != nil {
                            Button {
                                onMove?(album, -1)
                            } label: {
                                Label("Move left", systemImage: "arrow.left")
                            }
                            Button {
                                onMove?(album, 1)
                            } label: {
                                Label("Move right", systemImage: "arrow.right")
                            }
                        }
                        if let onDelete {
                            Button(role: .destructive) {
                                onDelete(album)
                            } label: {
                                Label("Remove theme", systemImage: "trash")
                            }
                        }
                    }
                }

                Button(action: onAdd) {
                    SprocketAddTile()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}
