import SwiftUI

#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

#if canImport(UserMessagingPlatform)
import UserMessagingPlatform
#endif

@Observable
@MainActor
final class AdConsentManager {
    private(set) var canRequestAds = false
    private(set) var privacyOptionsRequired = false

    private var hasPreparedAds = false
    private var hasStartedMobileAds = false

    func prepareAds() {
        guard !hasPreparedAds else { return }
        hasPreparedAds = true

        #if canImport(UserMessagingPlatform)
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = false

        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self] _ in
            ConsentForm.loadAndPresentIfRequired(from: nil) { [weak self] _ in
                Self.refreshAdPermission(for: self)
            }

            Self.refreshAdPermission(for: self)
        }
        #else
        canRequestAds = true
        privacyOptionsRequired = false
        startMobileAdsIfAllowed()
        #endif
    }

    func showPrivacyOptions() {
        #if canImport(UserMessagingPlatform)
        ConsentForm.presentPrivacyOptionsForm(from: nil) { [weak self] _ in
            Self.refreshAdPermission(for: self)
        }
        #endif
    }

    private nonisolated static func refreshAdPermission(for manager: AdConsentManager?) {
        Task { @MainActor in
            manager?.refreshAdPermission()
        }
    }

    private func refreshAdPermission() {
        #if canImport(UserMessagingPlatform)
        canRequestAds = ConsentInformation.shared.canRequestAds
        privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
        #endif

        startMobileAdsIfAllowed()
    }

    private func startMobileAdsIfAllowed() {
        guard canRequestAds, !hasStartedMobileAds else { return }
        hasStartedMobileAds = true

        #if canImport(GoogleMobileAds)
        MobileAds.shared.start(completionHandler: nil)
        #endif
    }
}
