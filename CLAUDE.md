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