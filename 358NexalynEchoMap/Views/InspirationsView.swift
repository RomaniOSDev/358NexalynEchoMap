import SwiftUI

struct InspirationsView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel = InspirationsViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BrushSectionTitle(title: "Collections")
                    .padding(.horizontal, 16)
                collectionStrip
                BrushSectionTitle(title: "Stills")
                    .padding(.horizontal, 16)
                if viewModel.visibleItems(store: store).isEmpty {
                    Text("No stills match that search.")
                        .font(.system(.body, design: .serif).italic())
                        .foregroundColor(Color("AppTextSecondary"))
                        .padding(.horizontal, 16)
                } else {
                    MasonryGrid(items: viewModel.visibleItems(store: store)) { index, item in
                        ZStack(alignment: .topTrailing) {
                            Button {
                                path.append(AppRoute.inspiration(item.id))
                            } label: {
                                MasonryCard(
                                    imageName: item.imageName,
                                    title: item.title,
                                    subtitle: item.collection,
                                    index: index
                                )
                            }
                            .buttonStyle(.plain)
                            MagentaIconButton(systemName: store.isFavorite(item.id) ? "heart.fill" : "heart") {
                                store.toggleFavorite(item.id)
                            }
                            .padding(10)
                        }
                    }
                }
            }
            .padding(.vertical, 16)
        }
        .studioCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Inspirations")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.openWallComposer()
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(Color("AppPrimary"))
                }
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .searchable(text: $viewModel.query, prompt: "Search stills")
        .scrollDismissesKeyboard(.immediately)
        .sheet(isPresented: $viewModel.wallComposerPresented) {
            wallComposer
        }
    }

    private var collectionStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                collectionChip(title: "All", image: BundledStill.palette.rawValue, shelf: .all)
                collectionChip(title: "Clay Studies", image: BundledStill.sculpture.rawValue, shelf: .catalog("Clay Studies"))
                collectionChip(title: "Palette Studies", image: BundledStill.palette.rawValue, shelf: .catalog("Palette Studies"))
                collectionChip(title: "Mood Walls", image: BundledStill.moodboard.rawValue, shelf: .catalog("Mood Walls"))
                ForEach(store.moodWalls) { wall in
                    collectionChip(
                        title: wall.title,
                        image: BundledStill.moodboard.rawValue,
                        shelf: .wall(wall.id)
                    )
                    .contextMenu {
                        Button(role: .destructive) {
                            store.deleteMoodWall(id: wall.id)
                            if viewModel.shelf == .wall(wall.id) {
                                viewModel.shelf = .all
                            }
                        } label: {
                            Label("Delete wall", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func collectionChip(title: String, image: String, shelf: InspirationsViewModel.Shelf) -> some View {
        Button {
            viewModel.shelf = shelf
        } label: {
            SprocketPoster(
                imageName: image,
                title: title,
                emojis: viewModel.shelf == shelf ? "●" : "○",
                isSelected: viewModel.shelf == shelf
            )
        }
        .buttonStyle(.plain)
    }

    private var wallComposer: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    BrushSectionTitle(title: "New mood wall")
                    TextField("Wall title", text: $viewModel.wallTitleDraft)
                        .foregroundColor(Color("AppTextPrimary"))
                        .padding(14)
                        .background(Color("AppSurface"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    if let error = viewModel.wallError {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(Color("AppPrimary"))
                    }
                    MagentaGradientButton(title: "Create wall", systemImage: "checkmark", fillWidth: true) {
                        viewModel.createWall(store: store)
                    }
                }
                .padding(20)
            }
            .studioCanvas()
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { viewModel.wallComposerPresented = false }
                        .foregroundColor(Color("AppPrimary"))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }
}
