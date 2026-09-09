import SwiftUI

struct TagChipStrip: View {
    let tags: [String]
    var selected: String?
    var onSelect: (String?) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", tag: nil)
                ForEach(tags, id: \.self) { tag in
                    chip(title: tag, tag: tag)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func chip(title: String, tag: String?) -> some View {
        let isOn = selected == tag
        return Button {
            onSelect(tag)
        } label: {
            Text(title)
                .font(.caption)
                .foregroundColor(isOn ? .white : Color("AppTextPrimary"))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background {
                    if isOn {
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
}
