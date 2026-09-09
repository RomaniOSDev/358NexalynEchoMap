import SwiftUI

struct TagManagerView: View {
    @EnvironmentObject private var store: DataStore
    @State private var renameSource: String?
    @State private var renameDraft = ""
    @State private var mergeSource: String?
    @State private var error: String?
    @State private var confirmDelete: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BrushSectionTitle(title: "Tags")
                if let error {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(Color("AppPrimary"))
                }
                if store.tagCounts().isEmpty {
                    EmptyStateCard(systemImage: "tag", message: "Tags will appear as you pin frames")
                } else {
                    ForEach(store.tagCounts(), id: \.tag) { item in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text(item.tag)
                                    .font(.system(.headline, design: .serif).italic())
                                    .foregroundColor(Color("AppTextPrimary"))
                                Spacer()
                                Text("\(item.count)")
                                    .foregroundColor(Color("AppTextSecondary"))
                            }
                            HStack(spacing: 8) {
                                MagentaGradientButton(title: "Rename", systemImage: "pencil") {
                                    renameSource = item.tag
                                    renameDraft = item.tag
                                    error = nil
                                }
                                MagentaGradientButton(title: "Merge", systemImage: "arrow.triangle.merge") {
                                    mergeSource = item.tag
                                    error = nil
                                }
                                Button("Delete") {
                                    confirmDelete = item.tag
                                }
                                .foregroundColor(Color("AppPrimary"))
                            }
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
                Text("Tags")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .alert("Rename tag", isPresented: renameAlert) {
            TextField("Tag", text: $renameDraft)
            Button("Save") {
                if let source = renameSource {
                    error = store.renameTag(from: source, to: renameDraft)
                }
                renameSource = nil
            }
            Button("Cancel", role: .cancel) { renameSource = nil }
        }
        .alert("Delete tag?", isPresented: deleteAlert) {
            Button("Delete", role: .destructive) {
                if let tag = confirmDelete {
                    store.deleteTag(tag)
                }
                confirmDelete = nil
            }
            Button("Keep", role: .cancel) { confirmDelete = nil }
        } message: {
            Text("This tag will be removed from every frame.")
        }
        .sheet(item: mergeItem) { source in
            mergeSheet(source.tag)
        }
    }

    private var renameAlert: Binding<Bool> {
        Binding(
            get: { renameSource != nil },
            set: { if !$0 { renameSource = nil } }
        )
    }

    private var deleteAlert: Binding<Bool> {
        Binding(
            get: { confirmDelete != nil },
            set: { if !$0 { confirmDelete = nil } }
        )
    }

    private var mergeItem: Binding<TagRef?> {
        Binding(
            get: { mergeSource.map(TagRef.init) },
            set: { mergeSource = $0?.tag }
        )
    }

    private func mergeSheet(_ source: String) -> some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    BrushSectionTitle(title: "Merge \(source)")
                    let targets = store.tagCounts().map(\.tag).filter { $0.caseInsensitiveCompare(source) != .orderedSame }
                    if targets.isEmpty {
                        Text("Create another tag first.")
                            .foregroundColor(Color("AppTextSecondary"))
                    } else {
                        ForEach(targets, id: \.self) { target in
                            MagentaGradientButton(title: target, systemImage: "arrow.triangle.merge", fillWidth: true) {
                                error = store.mergeTag(from: source, into: target)
                                mergeSource = nil
                            }
                        }
                    }
                }
                .padding(20)
            }
            .studioCanvas()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { mergeSource = nil }
                        .foregroundColor(Color("AppPrimary"))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDetents([.medium])
    }
}

private struct TagRef: Identifiable {
    var tag: String
    var id: String { tag }
}
