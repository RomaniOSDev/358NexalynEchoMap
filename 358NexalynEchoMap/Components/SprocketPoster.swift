import SwiftUI

struct SprocketPoster: View {
    let imageName: String
    let title: String
    let emojis: String
    var isSelected: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            frame
            HStack(spacing: 4) {
                Text(emojis)
                Text(title)
                    .font(.system(.caption, design: .serif).italic())
                    .foregroundColor(Color("AppTextPrimary"))
                    .lineLimit(1)
            }
            .frame(width: 112)
        }
    }

    private var frame: some View {
        VStack(spacing: 5) {
            sprocketRow
            GradientStill(imageName: imageName)
                .frame(width: 98, height: 74)
                .clipped()
            sprocketRow
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 7)
        .frame(width: 112, height: 112)
        .background(Color("AppSurface"))
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(isSelected ? Color("AppPrimary") : Color.white.opacity(0.08), lineWidth: isSelected ? 2 : 1)
        )
        .shadow(color: Color.black.opacity(0.5), radius: 16, x: 0, y: 10)
    }

    private var sprocketRow: some View {
        HStack(spacing: 5) {
            ForEach(0..<8, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color("AppBackground"))
                    .frame(width: 5, height: 7)
            }
        }
    }
}

struct SprocketAddTile: View {
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 5) {
                sprocketRow
                ZStack {
                    Color("AppSurface")
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(16)
                        .background(
                            LinearGradient(
                                colors: [Color("AppPrimary"), Color("AppAccent")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(Circle())
                }
                .frame(width: 98, height: 74)
                sprocketRow
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 7)
            .frame(width: 112, height: 112)
            .background(Color("AppSurface"))
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .shadow(color: Color.black.opacity(0.5), radius: 16, x: 0, y: 10)

            Text("New theme")
                .font(.system(.caption, design: .serif).italic())
                .foregroundColor(Color("AppTextSecondary"))
                .frame(width: 112)
        }
    }

    private var sprocketRow: some View {
        HStack(spacing: 5) {
            ForEach(0..<8, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 1)
                    .fill(Color("AppBackground"))
                    .frame(width: 5, height: 7)
            }
        }
    }
}
