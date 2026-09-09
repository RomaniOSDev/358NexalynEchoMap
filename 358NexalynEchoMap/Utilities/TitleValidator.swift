import Foundation

enum TitleValidator {
    static func validated(_ raw: String) -> (title: String?, error: String?) {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return (nil, "Give this theme a title")
        }
        if trimmed.count > 48 {
            return (nil, "Keep the title under 48 characters")
        }
        return (trimmed, nil)
    }
}
