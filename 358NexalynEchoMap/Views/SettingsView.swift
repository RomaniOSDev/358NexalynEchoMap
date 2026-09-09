import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var store: DataStore
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var path: NavigationPath

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BrushSectionTitle(title: "Settings")
                MasonryCard(
                    imageName: BundledStill.palette.rawValue,
                    title: "Studio desk",
                    subtitle: "Rate, policies, and a clean slate",
                    index: 0
                )
                MagentaGradientButton(title: "Tags", systemImage: "tag.fill", fillWidth: true) {
                    path.append(AppRoute.tagManager)
                }
                MagentaGradientButton(title: "Recently deleted", systemImage: "trash", fillWidth: true) {
                    path.append(AppRoute.recentlyDeleted)
                }
                MagentaGradientButton(title: "Rate Us", systemImage: "star.fill", fillWidth: true) {
                    viewModel.rateUs()
                }
                MagentaGradientButton(title: "Privacy", systemImage: "hand.raised.fill", fillWidth: true) {
                    viewModel.openPrivacy()
                }
                MagentaGradientButton(title: "Terms", systemImage: "doc.text.fill", fillWidth: true) {
                    viewModel.openTerms()
                }
                Button {
                    viewModel.confirmReset = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Reset")
                    }
                    .font(.headline)
                    .foregroundColor(Color("AppPrimary"))
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .overlay(
                        Capsule().stroke(Color("AppPrimary"), lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(20)
        }
        .studioCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Settings")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .alert("Reset studio?", isPresented: $viewModel.confirmReset) {
            Button("Reset", role: .destructive) {
                viewModel.reset(store: store)
            }
            Button("Keep", role: .cancel) {}
        } message: {
            Text("Themes, frames, annotations, favourites, and mood walls will be cleared.")
        }
    }
}
