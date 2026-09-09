import SwiftUI

struct MasonryCard: View {
    let imageName: String
    let title: String
    let subtitle: String
    let index: Int

    var body: some View {
        GradientStill(imageName: imageName)
            .frame(maxWidth: .infinity)
            .frame(height: index % 2 == 0 ? 228 : 168)
            .clipped()
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(.headline, design: .serif).italic())
                        .foregroundColor(Color("AppTextPrimary"))
                        .lineLimit(2)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(Color("AppTextSecondary"))
                        .lineLimit(2)
                }
                .padding(12)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: Color.black.opacity(0.55), radius: 16, x: 0, y: 10)
            .rotationEffect(.degrees(index % 2 == 0 ? -1 : 1))
    }
}

struct MasonryGrid<Item: Identifiable, Content: View>: View {
    let items: [Item]
    @ViewBuilder let content: (Int, Item) -> Content

    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                content(index, item)
            }
        }
        .padding(.horizontal, 16)
    }
}
