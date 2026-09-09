import SwiftUI

enum AppTheme {
    static let background = Color("AppBackground")
    static let primary = Color("AppPrimary")
    static let accent = Color("AppAccent")
    static let surface = Color("AppSurface")
    static let textPrimary = Color("AppTextPrimary")
    static let textSecondary = Color("AppTextSecondary")

    static let dateStamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

extension View {
    func studioCanvas() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Color("AppBackground").overlay {
                    Image("bg_studio").resizable().scaledToFill().opacity(0.26)
                }.clipped().ignoresSafeArea()
            }
    }
}
