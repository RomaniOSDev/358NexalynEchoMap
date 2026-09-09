import SwiftUI

struct BrushSectionTitle: View {
    let title: String

    var body: some View {
        ZStack {
            Capsule()
                .fill(Color("AppPrimary").opacity(0.55))
                .frame(width: 92, height: 14)
                .rotationEffect(.degrees(-12))
                .offset(x: -8, y: 7)
            Text(title)
                .font(.system(.title2, design: .serif).italic())
                .foregroundColor(Color("AppTextPrimary"))
        }
        .padding(.leading, 4)
    }
}
