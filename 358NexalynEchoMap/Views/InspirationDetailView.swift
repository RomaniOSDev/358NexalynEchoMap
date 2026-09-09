import SwiftUI

struct InspirationDetailView: View {
    @EnvironmentObject private var store: DataStore
    let inspirationID: String
    @Binding var path: NavigationPath
    @State private var pinPresented = false
    @State private var wallPresented = false

    private var item: Inspiration? {
        InspirationCatalog.items.first { $0.id == inspirationID }
    }

    var body: some View {
        Group {
            if let item {
                populated(item)
            } else {
                EmptyStateCard(systemImage: "film", message: "This still is no longer in the catalog")
                    .studioCanvas()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func populated(_ item: Inspiration) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                MasonryCard(
                    imageName: item.imageName,
                    title: item.title,
                    subtitle: item.collection,
                    index: 0
                )
                .padding(.horizontal, 16)
                BrushSectionTitle(title: item.title)
                    .padding(.horizontal, 16)
                Text(item.summary)
                    .font(.system(.body, design: .serif).italic())
                    .foregroundColor(Color("AppTextSecondary"))
                    .padding(.horizontal, 16)
                HStack(spacing: 8) {
                    ForEach(item.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .foregroundColor(Color("AppTextPrimary"))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color("AppSurface"))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 16)
                MagentaGradientButton(
                    title: "Pin as frame",
                    systemImage: "plus.square.on.square",
                    fillWidth: true
                ) {
                    pinPresented = true
                }
                .padding(.horizontal, 16)
                MagentaGradientButton(
                    title: "Add to mood wall",
                    systemImage: "rectangle.stack.badge.plus",
                    fillWidth: true
                ) {
                    wallPresented = true
                }
                .padding(.horizontal, 16)
                MagentaGradientButton(
                    title: store.isFavorite(item.id) ? "Favourited" : "Favourite",
                    systemImage: store.isFavorite(item.id) ? "heart.fill" : "heart",
                    fillWidth: true
                ) {
                    store.toggleFavorite(item.id)
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .studioCanvas()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(item.collection)
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    store.toggleFavorite(item.id)
                } label: {
                    Image(systemName: store.isFavorite(item.id) ? "heart.fill" : "heart")
                        .foregroundColor(Color("AppPrimary"))
                }
            }
        }
        .sheet(isPresented: $pinPresented) {
            pinSheet(item)
        }
        .sheet(isPresented: $wallPresented) {
            wallSheet(item)
        }
    }

    private func pinSheet(_ item: Inspiration) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    BrushSectionTitle(title: "Pin as frame")
                    if store.albums.isEmpty {
                        Text("Create a theme first.")
                            .foregroundColor(Color("AppTextSecondary"))
                    } else {
                        ForEach(store.sortedAlbums()) { album in
                            MagentaGradientButton(title: album.title, systemImage: "film", fillWidth: true) {
                                pinPresented = false
                                path.append(
                                    AppRoute.noteEditor(
                                        NoteDraftTarget(
                                            noteID: nil,
                                            albumID: album.id,
                                            prefills: NotePrefill(
                                                imageName: item.imageName,
                                                tags: item.tags,
                                                content: item.summary
                                            )
                                        )
                                    )
                                )
                            }
                        }
                    }
                }
                .padding(20)
            }
            .studioCanvas()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { pinPresented = false }
                        .foregroundColor(Color("AppPrimary"))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }

    private func wallSheet(_ item: Inspiration) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    BrushSectionTitle(title: "Mood walls")
                    if store.moodWalls.isEmpty {
                        Text("Create a mood wall in Inspirations first.")
                            .foregroundColor(Color("AppTextSecondary"))
                    } else {
                        ForEach(store.moodWalls) { wall in
                            MagentaGradientButton(
                                title: store.isInMoodWall(wallID: wall.id, itemID: item.id) ? "Remove from \(wall.title)" : "Add to \(wall.title)",
                                systemImage: store.isInMoodWall(wallID: wall.id, itemID: item.id) ? "minus" : "plus",
                                fillWidth: true
                            ) {
                                store.toggleMoodWallItem(wallID: wall.id, itemID: item.id)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .studioCanvas()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { wallPresented = false }
                        .foregroundColor(Color("AppPrimary"))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }
}
