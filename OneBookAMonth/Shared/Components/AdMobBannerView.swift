//
//  AdMobBannerView.swift
//  OneBookAMonth
//
//  Created by Assistant on 2025-09-14.
//

import SwiftUI
import GoogleMobileAds

struct AdMobBannerView: View {
    @State private var bannerView = BannerView(adSize: AdSizeBanner)
    
    // MARK: - Spacing Constants (8pt Grid System)
    private let spacing = (
        xs: CGFloat(4),
        sm: CGFloat(8),
        md: CGFloat(16),
        lg: CGFloat(24)
    )
    
    var body: some View {
        VStack(spacing: 0) {
            AdMobBannerViewRepresentable(bannerView: bannerView)
                .frame(height: 50) // Standard banner size
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: 1)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                )
        }
    }
}

struct AdMobBannerViewRepresentable: UIViewRepresentable {
    let bannerView: BannerView
    
    func makeUIView(context: Context) -> BannerView {
        // Test ad unit ID for banner ads
        bannerView.adUnitID = "ca-app-pub-9672225107682073/3947638113"
        
        // Set root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            bannerView.rootViewController = rootViewController
        }
        
        // Load ad
        let request = Request()
        bannerView.load(request)
        
        return bannerView
    }
    
    func updateUIView(_ uiView: BannerView, context: Context) {
        // No updates needed for static banner
    }
}

// MARK: - Preview
#Preview {
    AdMobBannerView()
        .padding()
}
