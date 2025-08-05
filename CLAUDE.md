# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OneBookAMonth is an iOS app for tracking reading habits and book progress, built with SwiftUI and SwiftData following MVVM architecture.

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

### MVVM Structure
```
OneBookAMonth/
├── Model/          # Data models and persistence
├── View/           # SwiftUI views and UI components  
├── ViewModel/      # Business logic and view models
```

### Key Models
- **Item**: Core book model with SwiftData `@Model` annotation
- **PageEntry**: Tracks daily reading progress with cascade delete relationship
- **ItemManager**: Singleton for data operations and analytics

### View Layer
- **ContentView**: Main tab navigation container
- **HomeViewModel**: Dashboard with calendar heatmap and stats
- **CompletedViewModel**: Library management with segmented control
- Reusable components: CircularProgressView, StatItemView, FloatingButtonView

### ViewModel Pattern
Each major view has a corresponding ViewModel:
- Handle user interactions
- Manage data flow between Model and View
- Contains business logic separated from UI

### Dependencies
- **HorizonCalendar** (Airbnb): Calendar visualization via Swift Package Manager
- **SwiftData**: Apple's persistence framework (requires iOS 17+)
- **AVFoundation**: Camera integration for book photos

## Important Considerations

### SwiftData Usage
- Models use `@Model` annotation
- Relationships defined with `@Relationship(deleteRule: .cascade)`
- ModelContext injected via environment

### Calendar Integration
- HorizonCalendar provides activity heatmap
- Custom day rendering in HomeViewModel
- Scroll-to-date functionality implemented

### Image Handling
- Camera permissions required (Info.plist configured)
- Images stored as Data in SwiftData model
- ImagePicker integration for photo capture

### App Configuration
- Portrait-only orientation
- Sandbox entitlements enabled
- Background modes for notifications