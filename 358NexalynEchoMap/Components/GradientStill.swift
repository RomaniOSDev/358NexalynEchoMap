import SwiftUI

struct GradientStill: View {
    let imageName: String

    var body: some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background {
                Image(imageName)
                    .resizable()
                    .scaledToFill()
            }
            .clipped()
            .overlay {
                LinearGradient(
                    colors: [Color.clear, Color("AppBackground").opacity(0.88)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
    }
}
