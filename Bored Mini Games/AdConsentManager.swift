import SwiftUI

#if canImport(AppTrackingTransparency)
import AppTrackingTransparency
#endif

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
    private var hasResolvedTrackingAuthorization = false

    func prepareAds() {
        guard !hasPreparedAds else { return }
        hasPreparedAds = true

        #if canImport(UserMessagingPlatform)
        let parameters = RequestParameters()
        parameters.isTaggedForUnderAgeOfConsent = false

        ConsentInformation.shared.requestConsentInfoUpdate(with: parameters) { [weak self] _ in
            ConsentForm.loadAndPresentIfRequired(from: nil) { [weak self] _ in
                Self.resolveTrackingAuthorization(for: self)
            }
        }
        #else
        resolveTrackingAuthorization()
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

    private nonisolated static func resolveTrackingAuthorization(for manager: AdConsentManager?) {
        Task { @MainActor in
            manager?.resolveTrackingAuthorization()
        }
    }

    private func resolveTrackingAuthorization() {
        guard !hasResolvedTrackingAuthorization else {
            refreshAdPermission()
            return
        }

        hasResolvedTrackingAuthorization = true

        #if canImport(AppTrackingTransparency)
        ATTrackingManager.requestTrackingAuthorization { [weak self] _ in
            Self.refreshAdPermission(for: self)
        }
        #else
        refreshAdPermission()
        #endif
    }

    private func refreshAdPermission() {
        #if canImport(UserMessagingPlatform)
        canRequestAds = ConsentInformation.shared.canRequestAds
        privacyOptionsRequired = ConsentInformation.shared.privacyOptionsRequirementStatus == .required
        #else
        canRequestAds = true
        privacyOptionsRequired = false
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
