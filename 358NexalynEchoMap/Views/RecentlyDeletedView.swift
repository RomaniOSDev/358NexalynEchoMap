import SwiftUI

struct RecentlyDeletedView: View {
    @EnvironmentObject private var store: DataStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BrushSectionTitle(title: "Recently deleted")
                if store.deletedAlbums.isEmpty && store.deletedNotes.isEmpty {
                    EmptyStateCard(systemImage: "trash", message: "Nothing in the bin")
                }
                if !store.deletedAlbums.isEmpty {
                    Text("Themes")
                        .font(.system(.headline, design: .serif).italic())
                        .foregroundColor(Color("AppTextSecondary"))
                    ForEach(store.deletedAlbums.reversed()) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(record.album.title)
                                    .font(.system(.headline, design: .serif).italic())
                                    .foregroundColor(Color("AppTextPrimary"))
                                Text("\(record.notes.count) frames")
                                    .font(.caption)
                                    .foregroundColor(Color("AppTextSecondary"))
                            }
                            Spacer()
                            MagentaGradientButton(title: "Restore", systemImage: "arrow.uturn.backward") {
                                store.restoreDeletedAlbum(id: record.id)
                            }
                        }
                        .padding(14)
                        .background(Color("AppSurface"))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                if !store.deletedNotes.isEmpty {
                    Text("Frames")
                        .font(.system(.headline, design: .serif).italic())
                        .foregroundColor(Color("AppTextSecondary"))
                    ForEach(store.deletedNotes.reversed()) { record in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(record.note.content)
                                    .font(.system(.headline, design: .serif).italic())
                                    .foregroundColor(Color("AppTextPrimary"))
                                    .lineLimit(2)
                                Text(restoreHint(for: record))
                                    .font(.caption)
                                    .foregroundColor(Color("AppTextSecondary"))
                            }
                            Spacer()
                            MagentaGradientButton(title: "Restore", systemImage: "arrow.uturn.backward") {
                                store.restoreDeletedNote(id: record.id)
                            }
                            .disabled(store.album(id: record.note.albumID) == nil)
                        }
                        .padding(14)
                        .background(Color("AppSurface"))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
            }
            .padding(20)
        }
        .studioCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Bin")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }

    private func restoreHint(for record: DeletedNoteRecord) -> String {
        if store.album(id: record.note.albumID) == nil {
            return "Restore the theme first"
        }
        return store.album(id: record.note.albumID)?.title ?? "Frame"
    }
}
