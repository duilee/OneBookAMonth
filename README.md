# OneBookAMonth

A SwiftUI app for tracking reading habits and book progress, designed to help you read at least one book every month.

## Features

- 📚 Track your reading progress with daily page entries
- 📊 Visualize reading habits with calendar heatmap
- 📈 View statistics and progress analytics
- 📷 Add book covers using camera or photo library
- 🎯 Set and monitor reading goals
- 📱 Clean, intuitive interface built with SwiftUI

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/OneBookAMonth.git
```

2. Open the project in Xcode:
```bash
cd OneBookAMonth
open OneBookAMonth.xcodeproj
```

3. Build and run the project (⌘ + R)

## Architecture

The app follows the MVVM (Model-View-ViewModel) pattern:

- **Models**: Core data models using SwiftData for persistence
- **Views**: SwiftUI views for the user interface
- **ViewModels**: Business logic and data management

## Dependencies

- **SwiftData**: Apple's modern persistence framework
- **HorizonCalendar**: Calendar visualization library by Airbnb
- **AVFoundation**: Camera integration for book photos

## Key Components

### Models
- `Item`: Core book model with reading progress tracking
- `PageEntry`: Daily reading entries with page counts
- `ItemManager`: Singleton for data operations and analytics

### Views
- `ContentView`: Main tab navigation
- `HomeView`: Dashboard with calendar and statistics
- `AddBookView`: Interface for adding new books
- `BookDetailView`: Detailed book information and progress

### Features
- Calendar heatmap showing reading activity
- Progress tracking with circular progress indicators
- Book library management with completion status
- Camera integration for book cover photos
- Reading statistics and analytics

## Usage

1. **Add a Book**: Tap the + button to add a new book with title, author, and page count
2. **Track Progress**: Log daily reading sessions with page numbers
3. **View Statistics**: Check your reading streak and progress on the home dashboard
4. **Manage Library**: View current and completed books in separate tabs

## Testing

Run tests using Xcode's test navigator (⌘ + U):
- Unit tests: `OneBookAMonthTests/`
- UI tests: `OneBookAMonthUITests/`

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request