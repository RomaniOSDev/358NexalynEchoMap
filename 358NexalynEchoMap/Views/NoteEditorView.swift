import SwiftUI

struct NoteEditorView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: NoteEditorViewModel

    init(config: NoteDraftTarget) {
        _viewModel = StateObject(wrappedValue: NoteEditorViewModel(config: config))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BrushSectionTitle(title: viewModel.noteID == nil ? "New frame" : "Edit frame")
                stillPicker
                Text("Note")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextSecondary"))
                TextEditor(text: $viewModel.content)
                    .frame(minHeight: 140)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .foregroundColor(Color("AppTextPrimary"))
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                if let error = viewModel.error {
                    Text(error)
                        .font(.footnote)
                        .foregroundColor(Color("AppPrimary"))
                }
                tagsBlock
                MagentaGradientButton(
                    title: "Save frame",
                    systemImage: "checkmark",
                    fillWidth: true
                ) {
                    if viewModel.save(store: store) {
                        dismiss()
                    }
                }
                if viewModel.noteID != nil {
                    MagentaGradientButton(
                        title: "Duplicate frame",
                        systemImage: "plus.square.on.square",
                        fillWidth: true
                    ) {
                        if let id = viewModel.noteID {
                            _ = store.duplicateNote(id: id)
                            dismiss()
                        }
                    }
                    Button(role: .destructive) {
                        if let id = viewModel.noteID {
                            store.deleteNote(id: id)
                            dismiss()
                        }
                    } label: {
                        Label("Delete frame", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 4)
                }
            }
            .padding(20)
        }
        .studioCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Frame")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear { viewModel.load(from: store) }
        .scrollDismissesKeyboard(.interactively)
    }

    private var stillPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Still")
                .font(.system(.headline, design: .serif).italic())
                .foregroundColor(Color("AppTextSecondary"))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(BundledStill.allCases) { still in
                        Button {
                            viewModel.imageName = still.rawValue
                        } label: {
                            SprocketPoster(
                                imageName: still.rawValue,
                                title: still.displayTitle,
                                emojis: viewModel.imageName == still.rawValue ? "●" : "○",
                                isSelected: viewModel.imageName == still.rawValue
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var tagsBlock: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tags")
                .font(.system(.headline, design: .serif).italic())
                .foregroundColor(Color("AppTextSecondary"))
            HStack {
                TextField("Add a tag", text: $viewModel.tagDraft)
                    .foregroundColor(Color("AppTextPrimary"))
                    .padding(12)
                    .background(Color("AppSurface"))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                MagentaIconButton(systemName: "plus") {
                    viewModel.addTag()
                }
            }
            if !viewModel.tags.isEmpty {
                FlowChips(tags: viewModel.tags) { tag in
                    viewModel.removeTag(tag)
                }
            }
            suggestedTagsRow
        }
    }

    private var suggestedTagsRow: some View {
        let suggestions = store.suggestedTags().filter { candidate in
            !viewModel.tags.contains { $0.caseInsensitiveCompare(candidate) == .orderedSame }
        }
        return Group {
            if !suggestions.isEmpty {
                Text("From themes")
                    .font(.caption)
                    .foregroundColor(Color("AppTextSecondary"))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(suggestions, id: \.self) { tag in
                            Button {
                                viewModel.applySuggested(tag)
                            } label: {
                                Text(tag)
                                    .font(.caption)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(
                                        LinearGradient(
                                            colors: [Color("AppPrimary"), Color("AppAccent")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

private struct FlowChips: View {
    let tags: [String]
    let onRemove: (String) -> Void

    var body: some View {
        FlexibleChipRow(tags: tags, onRemove: onRemove)
    }
}

private struct FlexibleChipRow: View {
    let tags: [String]
    let onRemove: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(tags, id: \.self) { tag in
                    Button {
                        onRemove(tag)
                    } label: {
                        HStack(spacing: 4) {
                            Text(tag)
                            Image(systemName: "xmark")
                                .font(.caption2)
                        }
                        .font(.caption)
                        .foregroundColor(Color("AppTextPrimary"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color("AppSurface"))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
