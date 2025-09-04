import Foundation

class OnboardingManager {
    static let shared = OnboardingManager()
    
    private let onboardingKey = "hasCompletedOnboarding"
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    var hasCompletedOnboarding: Bool {
        get { userDefaults.bool(forKey: onboardingKey) }
        set { userDefaults.set(newValue, forKey: onboardingKey) }
    }
    
    func shouldShowOnboarding() -> Bool {
        return !hasCompletedOnboarding
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }
    
    func resetOnboarding() {
        hasCompletedOnboarding = false
    }
}