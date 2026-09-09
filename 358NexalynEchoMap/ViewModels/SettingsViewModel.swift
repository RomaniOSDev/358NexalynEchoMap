import Foundation
import Combine

final class SettingsViewModel: ObservableObject {
    @Published var confirmReset = false

    func rateUs() {
        ReviewPrompter.request()
    }

    func openPrivacy() {
        AppLinks.open(AppLinks.privacy)
    }

    func openTerms() {
        AppLinks.open(AppLinks.terms)
    }

    func reset(store: DataStore) {
        store.resetAll()
        confirmReset = false
    }
}
