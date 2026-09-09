import SwiftUI

struct StudioHomeView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel = StudioViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                header
                undoBanner
                dailyCard
                FilmstripBar(
                    albums: store.sortedAlbums(),
                    selectedID: viewModel.selectedAlbumID,
                    coverImage: { store.coverImage(for: $0) },
                    onSelect: { album in
                        viewModel.selectedAlbumID = album.id
                        path.append(AppRoute.album(album.id))
                    },
                    onAdd: { viewModel.openComposer() },
                    onDelete: { store.deleteAlbum(id: $0.id) },
                    onMove: { album, offset in
                        store.moveAlbum(id: album.id, offset: offset)
                    },
                    onReorder: { source, target in
                        store.reorderAlbum(source, onto: target)
                    }
                )

                if store.albums.isEmpty {
                    EmptyStateCard(
                        systemImage: "lightbulb",
                        message: "Create your first inspiring theme"
                    )
                    MagentaGradientButton(title: "New Theme", systemImage: "plus") {
                        viewModel.openComposer()
                    }
                    .padding(.horizontal, 16)
                } else {
                    latestFrames
                }

                darkroom
            }
            .padding(.bottom, 28)
        }
        .studioCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Studio")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 12) {
                    Button {
                        path.append(AppRoute.search)
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color("AppPrimary"))
                    }
                    Button {
                        path.append(AppRoute.settings)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(Color("AppPrimary"))
                    }
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .sheet(isPresented: $viewModel.composerPresented) {
            AlbumComposerView(
                title: $viewModel.titleDraft,
                emojis: $viewModel.emojisDraft,
                coverImageName: $viewModel.coverDraft,
                error: viewModel.titleError,
                isEditing: false,
                onSave: {
                    if let album = viewModel.createAlbum(store: store) {
                        path.append(AppRoute.album(album.id))
                    }
                },
                onCancel: { viewModel.composerPresented = false }
            )
        }
        .onAppear { store.refreshDailyIfNeeded() }
    }

    private var header: some View {
        HStack {
            BrushSectionTitle(title: "Themes")
            Spacer()
            Menu {
                ForEach(ThemeSort.allCases) { sort in
                    Button {
                        store.setThemeSort(sort)
                    } label: {
                        if store.themeSort == sort {
                            Label(sort.title, systemImage: "checkmark")
                        } else {
                            Text(sort.title)
                        }
                    }
                }
            } label: {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundColor(Color("AppPrimary"))
                    .padding(8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var undoBanner: some View {
        if let message = store.undoBanner {
            HStack {
                Text(message)
                    .font(.system(.body, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
                Spacer()
                Button("Undo") { store.undoLast() }
                    .foregroundColor(Color("AppPrimary"))
                Button {
                    store.dismissUndoBanner()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(Color("AppTextSecondary"))
                }
            }
            .padding(14)
            .background(Color("AppSurface"))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.horizontal, 16)
        }
    }

    private var dailyCard: some View {
        let prompt = store.dailyPrompt()
        return Button {
            switch prompt.kind {
            case .still(let imageId):
                path.append(AppRoute.annotationEditor(imageId))
            case .inspiration(let id):
                path.append(AppRoute.inspiration(id))
            }
        } label: {
            HStack(spacing: 12) {
                GradientStill(imageName: prompt.imageName)
                    .frame(width: 72, height: 72)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(prompt.title)
                        .font(.system(.headline, design: .serif).italic())
                        .foregroundColor(Color("AppTextPrimary"))
                    Text(prompt.subtitle)
                        .font(.caption)
                        .foregroundColor(Color("AppTextSecondary"))
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(Color("AppPrimary"))
            }
            .padding(12)
            .background(Color("AppSurface"))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
    }

    private var latestFrames: some View {
        let frames = displayedFrames
        return VStack(alignment: .leading, spacing: 12) {
            BrushSectionTitle(title: "Frames")
                .padding(.horizontal, 16)
            if !store.allNoteTags().isEmpty {
                TagChipStrip(tags: store.allNoteTags(), selected: viewModel.tagFilter) { tag in
                    viewModel.tagFilter = tag
                }
            }
            if frames.isEmpty {
                Text(viewModel.tagFilter == nil ? "Open a reel to pin your first frame." : "No frames with that tag.")
                    .font(.system(.body, design: .serif).italic())
                    .foregroundColor(Color("AppTextSecondary"))
                    .padding(.horizontal, 16)
            } else {
                MasonryGrid(items: frames) { index, note in
                    Button {
                        path.append(AppRoute.noteEditor(NoteDraftTarget(noteID: note.id, albumID: note.albumID)))
                    } label: {
                        MasonryCard(
                            imageName: note.imageName,
                            title: note.content,
                            subtitle: store.album(id: note.albumID)?.title ?? "Theme",
                            index: index
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            path.append(AppRoute.noteEditor(NoteDraftTarget(noteID: note.id, albumID: note.albumID)))
                        } label: {
                            Label("Edit frame", systemImage: "pencil")
                        }
                        Button {
                            _ = store.duplicateNote(id: note.id)
                        } label: {
                            Label("Duplicate frame", systemImage: "plus.square.on.square")
                        }
                        moveMenu(for: note)
                        Button(role: .destructive) {
                            store.deleteNote(id: note.id)
                        } label: {
                            Label("Delete frame", systemImage: "trash")
                        }
                    }
                }
            }
        }
    }

    private var displayedFrames: [Note] {
        let matching = store.notesMatching(tag: viewModel.tagFilter)
        if viewModel.tagFilter == nil {
            return Array(matching.prefix(8))
        }
        return matching
    }

    private var darkroom: some View {
        VStack(alignment: .leading, spacing: 14) {
            BrushSectionTitle(title: "Darkroom")
                .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    darkroomPoster(
                        route: .annotations,
                        image: BundledStill.palette.rawValue,
                        title: "Annotations",
                        mark: "✏️"
                    )
                    darkroomPoster(
                        route: .inspirations,
                        image: BundledStill.moodboard.rawValue,
                        title: "Inspirations",
                        mark: "♡"
                    )
                    darkroomPoster(
                        route: .statistics,
                        image: BundledStill.sculpture.rawValue,
                        title: "Statistics",
                        mark: "▦"
                    )
                    darkroomPoster(
                        route: .compare,
                        image: BundledStill.palette.rawValue,
                        title: "Compare",
                        mark: "⧉"
                    )
                    darkroomPoster(
                        route: .focusTimer,
                        image: BundledStill.moodboard.rawValue,
                        title: "Focus",
                        mark: "◷"
                    )
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func darkroomPoster(route: AppRoute, image: String, title: String, mark: String) -> some View {
        Button {
            path.append(route)
        } label: {
            SprocketPoster(imageName: image, title: title, emojis: mark)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func moveMenu(for note: Note) -> some View {
        ForEach(store.albums.filter { $0.id != note.albumID }) { album in
            Button {
                store.moveNote(id: note.id, to: album.id)
            } label: {
                Label("Move to \(album.title)", systemImage: "arrow.right.square")
            }
        }
    }
}
