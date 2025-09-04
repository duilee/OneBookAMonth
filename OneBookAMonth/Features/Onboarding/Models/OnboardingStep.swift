import Foundation

enum OnboardingStep: Int, CaseIterable {
    case welcome = 0
    case addBook = 1
    case challenge = 2
    case reminder = 3
    
    var title: String {
        switch self {
        case .welcome:
            return "Welcome"
        case .addBook:
            return "Add Your First Book"
        case .challenge:
            return "Set a Reading Goal"
        case .reminder:
            return "Stay on Track"
        }
    }
    
    var isSkippable: Bool {
        switch self {
        case .welcome:
            return false
        case .addBook, .challenge, .reminder:
            return true
        }
    }
}