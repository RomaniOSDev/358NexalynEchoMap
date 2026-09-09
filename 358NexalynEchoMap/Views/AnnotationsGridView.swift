import SwiftUI

struct AnnotationsGridView: View {
    @EnvironmentObject private var store: DataStore
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BrushSectionTitle(title: "Annotations")
                    .padding(.horizontal, 16)
                if store.captions.isEmpty {
                    EmptyStateCard(systemImage: "pencil.circle", message: "No annotations yet")
                }
                MasonryGrid(items: BundledStill.allCases) { index, still in
                    Button {
                        path.append(AppRoute.annotationEditor(still.rawValue))
                    } label: {
                        MasonryCard(
                            imageName: still.rawValue,
                            title: still.displayTitle,
                            subtitle: store.captionSubtitle(for: still.rawValue),
                            index: index
                        )
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            path.append(AppRoute.annotationEditor(still.rawValue))
                        } label: {
                            Label("Edit annotation", systemImage: "pencil")
                        }
                        if store.caption(for: still.rawValue) != nil {
                            Button(role: .destructive) {
                                store.deleteCaption(imageId: still.rawValue)
                            } label: {
                                Label("Clear annotation", systemImage: "trash")
                            }
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
                Text("Annotations")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
    }
}
