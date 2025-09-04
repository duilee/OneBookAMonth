import Foundation
import SwiftUI
import SwiftData

@Observable
class OnboardingViewModel {
    var currentStep: OnboardingStep = .welcome
    var isOnboardingComplete = false
    var createdChallenge: Challenge?
    var addedBook: Item?
    
    private let userDefaults = UserDefaults.standard
    private let onboardingKey = "hasCompletedOnboarding"
    
    init() {
        checkOnboardingStatus()
    }
    
    func checkOnboardingStatus() {
        isOnboardingComplete = userDefaults.bool(forKey: onboardingKey)
    }
    
    func nextStep() {
        guard let currentIndex = OnboardingStep.allCases.firstIndex(of: currentStep) else { return }
        let nextIndex = currentIndex + 1
        
        if nextIndex < OnboardingStep.allCases.count {
            withAnimation {
                currentStep = OnboardingStep.allCases[nextIndex]
            }
        } else {
            completeOnboarding()
        }
    }
    
    func skipOnboarding() {
        completeOnboarding()
    }
    
    func completeOnboarding() {
        userDefaults.set(true, forKey: onboardingKey)
        withAnimation {
            isOnboardingComplete = true
        }
    }
    
    func shouldShowOnboarding() -> Bool {
        return !userDefaults.bool(forKey: onboardingKey)
    }
}