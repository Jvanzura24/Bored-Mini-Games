//
//  Bored_Mini_GamesApp.swift
//  Bored Mini Games
//
//  Created by Justin Vanzura on 7/17/26.
//

import SwiftUI
#if canImport(GoogleMobileAds)
import GoogleMobileAds
#endif

@main
struct Bored_Mini_GamesApp: App {
    init() {
        #if canImport(GoogleMobileAds)
        MobileAds.shared.start(completionHandler: nil)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
