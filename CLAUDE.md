# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OneBookAMonth is an iOS app for tracking reading habits, book progress, and reading challenges, built with SwiftUI and SwiftData following a feature-based MVVM architecture.

## Development Commands

### Building and Running
- **Build**: `⌘ + B` in Xcode
- **Run**: `⌘ + R` in Xcode
- **Test**: `⌘ + U` in Xcode
- **Clean Build**: `⌘ + Shift + K` in Xcode

### Testing
- Unit tests: Located in `OneBookAMonthTests/`
- UI tests: Located in `OneBookAMonthUITests/`
- Run single test: Click the diamond icon next to test method in Xcode
- Uses Swift Testing framework (`import Testing`)

## Architecture

### Feature-Based Structure
```
OneBookAMonth/
├── App/                    # Main app entry point and ContentView
├── Core/                   # Core functionality
│   ├── Models/            # Data models (Item, Challenge, Memo)
│   ├── Services/          # Business logic managers
│   └── Extensions/        # Swift extensions
├── Design/                 # ⭐ Design System (NEW)
│   ├── AppColors.swift    # Complete color palette with semantic naming
│   ├── AppTypography.swift # Semantic font scale with Dynamic Type
│   ├── Spacing.swift      # 8pt grid system + shadows
│   ├── AppIcons.swift     # Centralized SF Symbol definitions
│   ├── ButtonStyles.swift # Reusable button component styles
│   └── ViewModifiers.swift # Card styles and view extensions
├── Features/              # Feature modules
│   ├── BookDetail/        # Book detail and memo management
│   ├── Challenge/         # Reading challenges feature
│   ├── Library/           # Book library management
│   └── Stats/             # Statistics and analytics
├── Shared/                # Shared resources
│   ├── Components/        # Reusable UI components
│   ├── Resources/         # Assets and resources
│   └── Utils/             # Utility functions
└── Documentation/         # Project documentation
```

### Key Models
- **Item**: Core book model with SwiftData `@Model` annotation
  - Contains book metadata, cover image, reading progress
  - Has cascade delete relationships with PageEntry and Memo
- **PageEntry**: Tracks daily reading progress with cascade delete relationship
- **Memo**: Reading notes with optional image attachments
  - Supports text notes and photo attachments
  - Uses MemoImageManager for image storage optimization
- **Challenge**: Reading challenge model for goal tracking
  - Tracks start/end dates, target pages, and status
  - Supports notification reminders

### Service Layer
- **ItemManager**: Singleton for book data operations and analytics
- **ChallengeManager**: Manages reading challenges and goal tracking
- **NotificationManager**: Handles local notifications for reading reminders
- **MemoImageManager**: Manages memo image storage with thumbnail generation
- **ImagePicker**: Wrapper for camera/photo library access

### Main Features

#### Library (Tab 1)
- **LibraryView**: Book collection display with filtering
- **AddItemViewModel**: Book creation and metadata entry
- **BookCardView**: Compact book display component
- Supports reading/completed book segmentation

#### Challenge (Tab 2)
- **ChallengeView**: Active and past challenges display
- **CreateChallengeView**: Challenge creation wizard
- **ChallengeViewModel**: Challenge business logic and progress tracking
- **NotificationSettingsCard**: Daily reminder configuration
- **PastChallengeCard**: Historical challenge display

#### Stats (Tab 3)
- **StatsView**: Reading statistics dashboard
- **StatsViewModel**: Analytics calculations and data aggregation
- Calendar heatmap visualization of reading activity
- Monthly/yearly reading trends

### Shared Components
- **CircularProgressView**: Animated progress indicator
- **DeleteConfirmationViewModel**: Deletion confirmation dialogs
- **FloatingButtonView**: FAB-style action button
- **ImagePickerView**: Camera/photo library integration
- **LoadingView**: Loading state indicator
- **ProgressTagView**: Compact progress display

### ViewModel Pattern
Each major view has a corresponding ViewModel:
- Handles user interactions and business logic
- Manages data flow between Model and View
- Uses `@Observable` or `ObservableObject` for state management
- Separates UI concerns from business logic

### Dependencies
- **HorizonCalendar** (Airbnb): Calendar visualization via Swift Package Manager
- **SwiftData**: Apple's persistence framework (requires iOS 17+)
- **AVFoundation**: Camera integration for book photos
- **UserNotifications**: Local notification support

## Design System

OneBookAMonth uses a comprehensive design system inspired by ReadNow's professional architecture pattern. The design system provides consistency, maintainability, and a single source of truth for all design decisions.

### Design System Files (`Design/` folder)

#### AppColors.swift - Color Palette
**Primary Colors**:
- `primaryDeep` - Main brand color (25/255, 45/255, 155/255)
- `primaryMedium` - Secondary variant
- `primaryLight` - Accent variant

**Semantic Colors**:
- `successGreen`, `errorRed`, `warningOrange` - Status colors
- `accentBlue`, `accentCoral` - Highlights and loading states

**Status Colors** (for challenges):
- `statusPending`, `statusActive`, `statusCompleted`, `statusFailed`

**Neutral Palette**:
- `textPrimary`, `textSecondary`, `textTertiary` - Text hierarchy
- `backgroundPrimary`, `backgroundSecondary`, `surfaceColor` - Backgrounds
- `borderColor`, `dividerColor` - Separators

**Usage**: All colors support hex initializer: `Color(hex: "FF6B6B")`

#### AppTypography.swift - Type Scale
**Display Fonts**: `displayLarge`, `displayMedium`, `displaySmall`
**Heading Fonts**: `headingLarge`, `headingMedium`, `headingSmall`
**Body Fonts**: `bodyLarge`, `bodyMedium`, `bodySmall`
**Label Fonts**: `labelLarge`, `labelMedium`, `labelSmall`, `labelTiny`

**Special Purpose**:
- `buttonLabel`, `tabLabel`, `badgeLabel`
- `bookTitle`, `bookAuthor`, `bookPages`, `bookProgress`
- `challengeTitle`, `challengeStatus`, `challengeStats`

**All fonts support Dynamic Type** for accessibility.

#### Spacing.swift - Layout System
**8pt Grid**: `xxs (4)`, `xs (8)`, `sm (12)`, `md (16)`, `lg (20)`, `xl (24)`, `xxl (32)`, `xxxl (40)`, `massive (48)`

**Insets**: `screenEdge`, `screenHorizontal`, `cardPadding`, `buttonPadding`, `listItem`, `badge`

**Corner Radius**: `tiny (4)`, `small (8)`, `medium (12)`, `large (16)`, `xlarge (20)`, `xxlarge (24)`, `circle (28)`

**Shadow Presets**: `Shadow.small`, `Shadow.medium`, `Shadow.large`, `Shadow.fab`

#### AppIcons.swift - SF Symbols
Centralized icon definitions organized by category:
- Navigation: `add`, `close`, `back`, `forward`, `expand`
- Books: `book`, `bookFilled`, `bookCircle`, `bookPages`
- Camera & Photos: `camera`, `photo`, `photos`
- Status: `checkmark`, `checkmarkFilled`, `target`, `trophy`, `sparkles`
- Progress & Time: `timer`, `calendar`, `speedometer`, `clock`

**Usage**: `Image(systemName: AppIcon.camera)` instead of hardcoded strings

#### ButtonStyles.swift - Button Components
- `PrimaryButtonStyle` - Blue filled buttons
- `SecondaryButtonStyle` - Outlined buttons
- `AccentButtonStyle` - Highlighted actions
- `CompactButtonStyle` - Small CTAs
- `DestructiveButtonStyle` - Delete/remove actions
- `TextButtonStyle` - Text-only buttons

**Usage**: `.buttonStyle(PrimaryButtonStyle())`

#### ViewModifiers.swift - Reusable Modifiers
- `.cardStyle()` - Standard card appearance with shadow
- `.sectionStyle()` - Section backgrounds
- `.badgeStyle(color:)` - Status badges
- `.progressCardStyle()` - Book card styling
- `.statCardStyle()` - Statistics displays

### Design System Usage Patterns

**Colors**:
```swift
Text("Hello")
    .foregroundColor(.primaryDeep)  // ✅ Semantic
    .background(.surfaceColor)      // ✅ Semantic

// ❌ DON'T: Color(red: 25/255, green: 45/255, blue: 155/255)
```

**Typography**:
```swift
Text("Book Title")
    .font(.bookTitle)         // ✅ Semantic
Text("Chapter 5")
    .font(.bodyMedium)        // ✅ Semantic

// ❌ DON'T: .font(.system(size: 18, weight: .bold))
```

**Spacing**:
```swift
VStack(spacing: Spacing.md) {  // ✅ Using scale
    Text("Title")
        .padding(Spacing.lg)    // ✅ Using scale
}
.cardStyle()                   // ✅ Using modifier

// ❌ DON'T: .padding(16) or .cornerRadius(12)
```

**Icons**:
```swift
Image(systemName: AppIcon.book)        // ✅ Centralized
Image(systemName: AppIcon.checkmark)   // ✅ Centralized

// ❌ DON'T: Image(systemName: "book.fill")
```

**Buttons**:
```swift
Button("Save") { }
    .buttonStyle(PrimaryButtonStyle())    // ✅ Reusable style

// ❌ DON'T: Inline padding, background, colors
```

### Migration Notes

**Before Design System** (Old Pattern):
```swift
private let primaryColor = Color(red: 25/255, green: 45/255, blue: 155/255)

Text(challenge.name)
    .font(.system(size: 18, weight: .bold))
    .foregroundColor(primaryColor)
    .padding(16)
    .background(Color.white)
    .cornerRadius(12)
    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
```

**After Design System** (New Pattern):
```swift
Text(challenge.name)
    .font(.challengeTitle)
    .foregroundColor(.primaryDeep)
    .cardStyle()
```

### Benefits
- ✅ **Zero color duplication** - Primary color was hardcoded in 10+ files
- ✅ **Consistent spacing** - 8pt grid system throughout
- ✅ **Semantic naming** - Code is self-documenting
- ✅ **Easy theming** - Change one value, update everywhere
- ✅ **Dynamic Type support** - Accessibility built-in
- ✅ **Comprehensive previews** - Design system documented visually

## Important Considerations

### SwiftData Usage
- Models use `@Model` annotation
- Relationships defined with `@Relationship(deleteRule: .cascade)`
- ModelContext injected via environment
- Query operations use `@Query` property wrapper

### Challenge System
- Supports multiple active/inactive challenges
- Automatic status management (pending, active, completed, failed)
- Progress tracking with pages read at start/end
- Optional daily notification reminders

### Memo System
- Text notes attached to books with timestamps
- Optional photo attachments with automatic thumbnail generation
- Full-size images stored in documents directory
- Thumbnails stored in SwiftData for performance

### Calendar Integration
- HorizonCalendar provides activity heatmap
- Custom day rendering for reading activity
- Scroll-to-date functionality implemented
- Monthly/yearly view switching

### Image Handling
- Camera permissions required (Info.plist configured)
- Book covers stored as Data in SwiftData model
- Memo images use separate file storage with thumbnails
- ImagePicker supports both camera and photo library

### Notification System
- Local notifications for reading reminders
- Per-challenge notification settings
- Daily notification at user-specified time
- Automatic permission request handling

### App Configuration
- Portrait-only orientation
- Sandbox entitlements enabled
- Background modes for notifications
- Minimum iOS 17.0 deployment target