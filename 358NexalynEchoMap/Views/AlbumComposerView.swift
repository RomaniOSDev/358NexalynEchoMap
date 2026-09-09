import SwiftUI

struct AlbumComposerView: View {
    @Binding var title: String
    @Binding var emojis: String
    @Binding var coverImageName: String?
    var error: String?
    let isEditing: Bool
    let onSave: () -> Void
    let onCancel: () -> Void

    private let emojiChoices = ["🎞️", "🎨", "🖼️", "🌙", "🏺", "💫"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    BrushSectionTitle(title: isEditing ? "Retitle" : "New theme")
                    TextField("Theme title", text: $title)
                        .font(.system(.title3, design: .serif).italic())
                        .foregroundColor(Color("AppTextPrimary"))
                        .padding(14)
                        .background(Color("AppSurface"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    if let error {
                        Text(error)
                            .font(.footnote)
                            .foregroundColor(Color("AppPrimary"))
                    }
                    Text("Mark")
                        .font(.system(.headline, design: .serif).italic())
                        .foregroundColor(Color("AppTextSecondary"))
                    HStack(spacing: 10) {
                        ForEach(emojiChoices, id: \.self) { mark in
                            Button {
                                emojis = mark
                            } label: {
                                Text(mark)
                                    .font(.title2)
                                    .padding(10)
                                    .background(emojis == mark ? Color("AppPrimary").opacity(0.35) : Color("AppSurface"))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    TextField("Custom mark", text: $emojis)
                        .foregroundColor(Color("AppTextPrimary"))
                        .padding(12)
                        .background(Color("AppSurface"))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    Text("Cover")
                        .font(.system(.headline, design: .serif).italic())
                        .foregroundColor(Color("AppTextSecondary"))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            Button {
                                coverImageName = nil
                            } label: {
                                VStack(spacing: 8) {
                                    ZStack {
                                        Color("AppSurface")
                                        Text("Auto")
                                            .font(.system(.caption, design: .serif).italic())
                                            .foregroundColor(Color("AppTextPrimary"))
                                    }
                                    .frame(width: 98, height: 74)
                                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                                            .stroke(coverImageName == nil ? Color("AppPrimary") : Color.white.opacity(0.08), lineWidth: coverImageName == nil ? 2 : 1)
                                    )
                                    Text("First frame")
                                        .font(.system(.caption, design: .serif).italic())
                                        .foregroundColor(Color("AppTextSecondary"))
                                }
                            }
                            .buttonStyle(.plain)
                            ForEach(BundledStill.allCases) { still in
                                Button {
                                    coverImageName = still.rawValue
                                } label: {
                                    SprocketPoster(
                                        imageName: still.rawValue,
                                        title: still.displayTitle,
                                        emojis: coverImageName == still.rawValue ? "●" : "○",
                                        isSelected: coverImageName == still.rawValue
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    MagentaGradientButton(
                        title: isEditing ? "Save theme" : "Create theme",
                        systemImage: "checkmark",
                        fillWidth: true,
                        action: onSave
                    )
                }
                .padding(20)
            }
            .studioCanvas()
            .scrollDismissesKeyboard(.interactively)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onCancel)
                        .foregroundColor(Color("AppPrimary"))
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDetents([.medium, .large])
    }
}
