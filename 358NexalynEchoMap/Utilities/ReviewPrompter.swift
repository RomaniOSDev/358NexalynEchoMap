import StoreKit
import UIKit

enum ReviewPrompter {
    static func request() {
        let scene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first { $0.activationState == .foregroundActive }
        guard let scene else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}
