//
//  BannerAdView.swift
//  Bored Mini Games
//
//  Shows a standard 320x50 banner ad at the bottom of the home screen.
//
//  SETUP: This file compiles with or without the Google Mobile Ads SDK.
//  To enable real ads:
//    1. In Xcode: File > Add Package Dependencies…
//       https://github.com/googleads/swift-package-manager-google-mobile-ads
//    2. Add your AdMob app ID to the target's Info tab as
//       "GADApplicationIdentifier" (a String).
//    3. Replace the test IDs in AdConfig below with your real IDs.
//  Until the SDK is added, the banner area is simply empty.
//

import SwiftUI

enum AdConfig {
    static let bannerAdUnitID = "ca-app-pub-3839631796835260/1811189935"
    static let interstitialAdUnitID = "ca-app-pub-3839631796835260/6663674328"
}

#if canImport(GoogleMobileAds)
import GoogleMobileAds

struct BannerAdView: View {
    let canRequestAds: Bool

    init(canRequestAds: Bool = true) {
        self.canRequestAds = canRequestAds
    }

    var body: some View {
        if canRequestAds {
            BannerAdRepresentable()
                .frame(height: 50)
                .frame(maxWidth: .infinity)
        }
    }
}

private struct BannerAdRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = AdConfig.bannerAdUnitID
        banner.rootViewController = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.keyWindow?.rootViewController
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}
}
#else
struct BannerAdView: View {
    let canRequestAds: Bool

    init(canRequestAds: Bool = true) {
        self.canRequestAds = canRequestAds
    }

    var body: some View {
        // Google Mobile Ads SDK not installed yet; reserve no space.
        EmptyView()
    }
}
#endif
