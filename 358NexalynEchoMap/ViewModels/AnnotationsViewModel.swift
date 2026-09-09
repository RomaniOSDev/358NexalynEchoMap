import Foundation
import Combine

final class AnnotationsViewModel: ObservableObject {
    @Published var captionText = ""
    @Published var strokes: [InkStroke] = []
    @Published var tool: InkTool = .pencil
    @Published var error: String?

    func stills() -> [BundledStill] {
        BundledStill.allCases
    }

    func loadCaption(imageId: String, store: DataStore) {
        let caption = store.caption(for: imageId)
        captionText = caption?.text ?? ""
        strokes = caption?.strokes ?? []
        error = nil
    }

    func applySuggested(_ tag: String) {
        let piece = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !piece.isEmpty else { return }
        if captionText.isEmpty {
            captionText = piece
        } else if !captionText.lowercased().contains(piece.lowercased()) {
            captionText += " · " + piece
        }
    }

    func undoStroke() {
        if !strokes.isEmpty {
            strokes.removeLast()
        }
    }

    func clearStrokes() {
        strokes = []
    }

    func save(imageId: String, store: DataStore) -> Bool {
        let trimmed = captionText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty && strokes.isEmpty {
            error = "Write a caption or sketch on the still"
            return false
        }
        error = nil
        store.upsertCaption(imageId: imageId, text: trimmed, strokes: strokes)
        return true
    }
}
