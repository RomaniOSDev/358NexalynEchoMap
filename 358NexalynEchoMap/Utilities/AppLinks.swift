import UIKit

enum AppLinks {
    static let privacy = "https://nexalyn358echomap.site/privacy/455"
    static let terms = "https://nexalyn358echomap.site/terms/455"

    static func open(_ address: String) {
        if let url = URL(string: address) {
            UIApplication.shared.open(url)
        }
    }
}
