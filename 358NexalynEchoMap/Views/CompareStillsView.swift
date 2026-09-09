import SwiftUI

struct CompareStillsView: View {
    @EnvironmentObject private var store: DataStore
    @State private var left: ComparePick = .still(BundledStill.sculpture.rawValue)
    @State private var right: ComparePick = .still(BundledStill.palette.rawValue)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                BrushSectionTitle(title: "Compare")
                HStack(alignment: .top, spacing: 10) {
                    pane(pick: left)
                    pane(pick: right)
                }
                BrushSectionTitle(title: "Left")
                picker(selection: $left)
                BrushSectionTitle(title: "Right")
                picker(selection: $right)
            }
            .padding(20)
        }
        .studioCanvas()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Compare")
                    .font(.system(.headline, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
            }
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .onAppear {
            if let first = store.notes.first, let second = store.notes.dropFirst().first {
                left = .note(first.id)
                right = .note(second.id)
            }
        }
    }

    private var options: [ComparePick] {
        var items: [ComparePick] = BundledStill.allCases.map { .still($0.rawValue) }
        items.append(contentsOf: store.notes.map { .note($0.id) })
        return items
    }

    private func pane(pick: ComparePick) -> some View {
        let resolved = resolve(pick)
        return VStack(alignment: .leading, spacing: 8) {
            GradientStill(imageName: resolved.imageName)
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            Text(resolved.title)
                .font(.system(.headline, design: .serif).italic())
                .foregroundColor(Color("AppTextPrimary"))
                .lineLimit(2)
            Text(resolved.subtitle)
                .font(.caption)
                .foregroundColor(Color("AppTextSecondary"))
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func picker(selection: Binding<ComparePick>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(options) { option in
                    let resolved = resolve(option)
                    Button {
                        selection.wrappedValue = option
                    } label: {
                        SprocketPoster(
                            imageName: resolved.imageName,
                            title: resolved.title,
                            emojis: selection.wrappedValue == option ? "●" : "○",
                            isSelected: selection.wrappedValue == option
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func resolve(_ pick: ComparePick) -> (imageName: String, title: String, subtitle: String) {
        switch pick {
        case .still(let name):
            let title = BundledStill(rawValue: name)?.displayTitle ?? "Still"
            return (name, title, "Studio still")
        case .note(let id):
            if let note = store.note(id: id) {
                return (
                    note.imageName,
                    note.content,
                    store.album(id: note.albumID)?.title ?? "Frame"
                )
            }
            return (BundledStill.palette.rawValue, "Frame", "Missing")
        }
    }
}

private enum ComparePick: Hashable, Identifiable {
    case still(String)
    case note(UUID)

    var id: String {
        switch self {
        case .still(let name): return "still-\(name)"
        case .note(let id): return "note-\(id)"
        }
    }
}
