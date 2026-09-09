import SwiftUI

struct AnnotationEditorView: View {
    @EnvironmentObject private var store: DataStore
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = AnnotationsViewModel()
    let imageId: String

    private var still: BundledStill? {
        BundledStill(rawValue: imageId)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BrushSectionTitle(title: still?.displayTitle ?? "Annotation")
                ZStack {
                    GradientStill(imageName: imageId)
                    InkCanvas(strokes: $viewModel.strokes, tool: viewModel.tool)
                }
                .frame(height: 228)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                HStack(spacing: 10) {
                    toolButton(.pencil, title: "Pencil")
                    toolButton(.marker, title: "Marker")
                    Spacer()
                    Button("Undo") { viewModel.undoStroke() }
                        .foregroundColor(Color("AppPrimary"))
                    Button("Clear") { viewModel.clearStrokes() }
                        .foregroundColor(Color("AppPrimary"))
                }
                Text("Caption")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextSecondary"))
                TextEditor(text: $viewModel.captionText)
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
                suggestions
                MagentaGradientButton(
                    title: "Save annotation",
                    systemImage: "checkmark",
                    fillWidth: true
                ) {
                    if viewModel.save(imageId: imageId, store: store) {
                        dismiss()
                    }
                }
                if store.caption(for: imageId) != nil {
                    Button(role: .destructive) {
                        store.deleteCaption(imageId: imageId)
                        dismiss()
                    } label: {
                        Label("Clear annotation", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(20)
        }
        .studioCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Caption")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear { viewModel.loadCaption(imageId: imageId, store: store) }
        .scrollDismissesKeyboard(.interactively)
    }

    private func toolButton(_ tool: InkTool, title: String) -> some View {
        Button {
            viewModel.tool = tool
        } label: {
            Text(title)
                .font(.caption)
                .foregroundColor(viewModel.tool == tool ? .white : Color("AppTextPrimary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    if viewModel.tool == tool {
                        Capsule().fill(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    } else {
                        Capsule().fill(Color("AppSurface"))
                    }
                }
        }
        .buttonStyle(.plain)
    }

    private var suggestions: some View {
        let tags = store.suggestedTags()
        return Group {
            if !tags.isEmpty {
                Text("Suggested from themes")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextSecondary"))
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
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
