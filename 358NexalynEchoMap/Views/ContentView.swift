import SwiftUI

struct ContentView: View {
    @StateObject private var store = DataStore()
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            StudioHomeView(path: $path)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .album(let id):
                        AlbumDetailView(albumID: id, path: $path)
                    case .noteEditor(let config):
                        NoteEditorView(config: config)
                    case .annotations:
                        AnnotationsGridView(path: $path)
                    case .annotationEditor(let imageId):
                        AnnotationEditorView(imageId: imageId)
                    case .inspirations:
                        InspirationsView(path: $path)
                    case .inspiration(let id):
                        InspirationDetailView(inspirationID: id, path: $path)
                    case .statistics:
                        StatisticsView()
                    case .settings:
                        SettingsView(path: $path)
                    case .search:
                        StudioSearchView(path: $path)
                    case .tagManager:
                        TagManagerView()
                    case .compare:
                        CompareStillsView()
                    case .focusTimer:
                        FocusTimerView()
                    case .recentlyDeleted:
                        RecentlyDeletedView()
                    }
                }
        }
        .environmentObject(store)
        .preferredColorScheme(.dark)
        .tint(Color("AppPrimary"))
    }
}
