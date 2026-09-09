import SwiftUI

struct EmptyStateCard: View {
    let systemImage: String
    let message: String

    var body: some View {
        VStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundColor(Color("AppPrimary"))
            Text(message)
                .font(.system(.title3, design: .serif).italic())
                .foregroundColor(Color("AppTextPrimary"))
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: .infinity)
    }
}
