//
//  SettingsViewModel.swift
//  OneBookAMonth
//
//  Settings screen business logic
//

import Foundation
import SwiftUI
import StoreKit

@Observable
class SettingsViewModel {
    // MARK: - Properties

    var showResetAlert = false
    var showResetSuccess = false

    // MARK: - Computed Properties

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    var versionText: String {
        "Version \(appVersion)"
    }

    var copyrightText: String {
        let year = Calendar.current.component(.year, from: Date())
        return "© \(year) OneBookAMonth"
    }

    // MARK: - Actions

    func resetOnboarding() {
        // Clear the onboarding completion flag
        OnboardingManager.shared.resetOnboarding()
        showResetAlert = false
        showResetSuccess = true
    }

    func promptForReview() {
        // Use StoreKit's native review prompt
        // This is the recommended approach - Apple limits to 3 times per year per user
        // It shows a native iOS review sheet without leaving the app

        if let scene = UIApplication.shared.connectedScenes.first(where: {
            $0.activationState == .foregroundActive
        }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

//     Optional: Direct App Store link if you want a fallback
     func openAppStoreForReview() {
         // Replace YOUR_APP_ID with actual App Store Connect app ID
         let appID = "6744606274"
         if let url = URL(string: "https://apps.apple.com/app/id\(appID)?action=write-review") {
             UIApplication.shared.open(url)
         }
     }
}
