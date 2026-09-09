import SwiftUI

struct AlbumDetailView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel: AlbumDetailViewModel
    @Binding var path: NavigationPath

    init(albumID: UUID, path: Binding<NavigationPath>) {
        _viewModel = StateObject(wrappedValue: AlbumDetailViewModel(albumID: albumID))
        _path = path
    }

    var body: some View {
        Group {
            if let album = store.album(id: viewModel.albumID) {
                populated(album)
            } else {
                EmptyStateCard(systemImage: "film", message: "This theme is no longer on the reel")
                    .studioCanvas()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.composerPresented) {
            AlbumComposerView(
                title: $viewModel.titleDraft,
                emojis: $viewModel.emojisDraft,
                coverImageName: $viewModel.coverDraft,
                error: viewModel.titleError,
                isEditing: true,
                onSave: { _ = viewModel.saveAlbum(store: store) },
                onCancel: { viewModel.composerPresented = false }
            )
        }
        .sheet(item: $viewModel.moveNote) { note in
            moveSheet(note)
        }
    }

    private func populated(_ album: Album) -> some View {
        let frames = store.notes(in: album.id, tag: viewModel.tagFilter)
        let related = store.relatedInspirations(for: album)
        let relatedFrames = store.relatedNotes(for: album)
        let albumTags = Array(Set(store.notes(in: album.id).flatMap(\.tags))).sorted()
        return ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(alignment: .center, spacing: 12) {
                    SprocketPoster(
                        imageName: store.coverImage(for: album),
                        title: album.title,
                        emojis: album.emojis,
                        isSelected: true
                    )
                    VStack(alignment: .leading, spacing: 10) {
                        Text(album.title)
                            .font(.system(.title, design: .serif).italic())
                            .foregroundColor(Color("AppTextPrimary"))
                        Text("\(store.notes(in: album.id).count) frames")
                            .foregroundColor(Color("AppTextSecondary"))
                        HStack(spacing: 10) {
                            MagentaIconButton(systemName: "plus") {
                                path.append(AppRoute.noteEditor(NoteDraftTarget(noteID: nil, albumID: album.id)))
                            }
                            MagentaIconButton(systemName: "pencil") {
                                viewModel.loadDraft(from: album)
                                viewModel.composerPresented = true
                            }
                        }
                    }
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)

                BrushSectionTitle(title: "Reel")
                    .padding(.horizontal, 16)

                if !albumTags.isEmpty {
                    TagChipStrip(tags: albumTags, selected: viewModel.tagFilter) { tag in
                        viewModel.tagFilter = tag
                    }
                }

                if frames.isEmpty {
                    EmptyStateCard(
                        systemImage: "lightbulb",
                        message: viewModel.tagFilter == nil ? "Pin your first frame to this theme" : "No frames with that tag"
                    )
                    MagentaGradientButton(title: "New frame", systemImage: "plus") {
                        path.append(AppRoute.noteEditor(NoteDraftTarget(noteID: nil, albumID: album.id)))
                    }
                    .padding(.horizontal, 16)
                } else {
                    MasonryGrid(items: frames) { index, note in
                        Button {
                            path.append(AppRoute.noteEditor(NoteDraftTarget(noteID: note.id, albumID: album.id)))
                        } label: {
                            MasonryCard(
                                imageName: note.imageName,
                                title: note.content,
                                subtitle: note.tags.isEmpty ? album.emojis : note.tags.joined(separator: " · "),
                                index: index
                            )
                        }
                        .buttonStyle(.plain)
                        .contextMenu {
                            Button {
                                path.append(AppRoute.noteEditor(NoteDraftTarget(noteID: note.id, albumID: album.id)))
                            } label: {
                                Label("Edit frame", systemImage: "pencil")
                            }
                            Button {
                                _ = store.duplicateNote(id: note.id)
                            } label: {
                                Label("Duplicate frame", systemImage: "plus.square.on.square")
                            }
                            Button {
                                viewModel.moveNote = note
                            } label: {
                                Label("Move to another theme", systemImage: "arrow.right.square")
                            }
                            ForEach(viewModel.destinationAlbums(store: store)) { target in
                                Button {
                                    store.moveNote(id: note.id, to: target.id)
                                } label: {
                                    Label("Move to \(target.title)", systemImage: "film")
                                }
                            }
                            Button(role: .destructive) {
                                store.deleteNote(id: note.id)
                            } label: {
                                Label("Delete frame", systemImage: "trash")
                            }
                        }
                    }
                    MagentaGradientButton(title: "Move a frame", systemImage: "arrow.right.square") {
                        viewModel.moveNote = frames.first
                    }
                    .padding(.horizontal, 16)
                }

                if !relatedFrames.isEmpty {
                    BrushSectionTitle(title: "Related frames")
                        .padding(.horizontal, 16)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(relatedFrames) { note in
                                Button {
                                    path.append(AppRoute.noteEditor(NoteDraftTarget(noteID: note.id, albumID: note.albumID)))
                                } label: {
                                    SprocketPoster(
                                        imageName: note.imageName,
                                        title: note.content,
                                        emojis: store.album(id: note.albumID)?.emojis ?? "🎞️"
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                if !related.isEmpty {
                    BrushSectionTitle(title: "Related")
                        .padding(.horizontal, 16)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 14) {
                            ForEach(related) { item in
                                Button {
                                    path.append(AppRoute.inspiration(item.id))
                                } label: {
                                    SprocketPoster(
                                        imageName: item.imageName,
                                        title: item.title,
                                        emojis: "♡"
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .studioCanvas()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(album.title)
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
        }
    }

    private func moveSheet(_ note: Note) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    BrushSectionTitle(title: "Move frame")
                    Text(note.content)
                        .font(.system(.body, design: .serif).italic())
                        .foregroundColor(Color("AppTextSecondary"))
                    if viewModel.destinationAlbums(store: store).isEmpty {
                        Text("Create another theme first.")
                            .foregroundColor(Color("AppTextSecondary"))
                    } else {
                        ForEach(viewModel.destinationAlbums(store: store)) { album in
                            MagentaGradientButton(title: album.title, systemImage: "film", fillWidth: true) {
                                store.moveNote(id: note.id, to: album.id)
                                viewModel.moveNote = nil
                            }
                        }
                    }
                }
                .padding(20)
            }
            .studioCanvas()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { viewModel.moveNote = nil }
                        .foregroundColor(Color("AppPrimary"))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }
}
