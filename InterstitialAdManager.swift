//
//  InterstitialAdManager.swift
//  Bored Mini Games
//

import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds

@Observable
@MainActor
final class InterstitialAdCoordinator {
    private(set) var isReady = false
    private var interstitialAd: InterstitialAd?

    func loadAd(canRequestAds: Bool = true) {
        guard canRequestAds else { return }

        Task {
            do {
                interstitialAd = try await InterstitialAd.load(
                    with: AdConfig.interstitialAdUnitID,
                    request: Request()
                )
                isReady = true
            } catch {}
        }
    }

    func showAd() {
        guard isReady,
              let ad = interstitialAd,
              let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = scene.keyWindow?.rootViewController else { return }
        isReady = false
        interstitialAd = nil
        ad.present(from: rootVC)
    }
}
#else
@Observable
@MainActor
final class InterstitialAdCoordinator {
    private(set) var isReady = false
    func loadAd(canRequestAds: Bool = true) {}
    func showAd() {}
}
#endif
