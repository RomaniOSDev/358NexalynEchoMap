import SwiftUI

struct MagentaGradientButton: View {
    let title: String
    let systemImage: String
    var fillWidth: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(maxWidth: fillWidth ? .infinity : nil)
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

struct MagentaIconButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.headline)
                .foregroundColor(.white)
                .padding(10)
                .background(
                    LinearGradient(
                        colors: [Color("AppPrimary"), Color("AppAccent")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}
