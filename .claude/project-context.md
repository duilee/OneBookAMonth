# OneBookAMonth Project Context

## 🎯 Project Overview
OneBookAMonth is an iOS app designed to help users build and maintain consistent reading habits by tracking their daily reading progress, visualizing achievements, and providing motivational insights.

## 📱 Core Features

### Current Implementation
- **Reading Progress Tracking**: Simple page entry with SwiftData persistence
- **Calendar Heatmap**: Visual representation of daily reading activity using HorizonCalendar
- **Book Library**: Organized view of currently reading, completed, and wishlist books
- **Statistics Dashboard**: Reading streaks, pages read, books completed, reading velocity
- **Book Photos**: Camera integration for capturing book covers
- **Quick Entry**: Floating action button for frictionless page logging

### Technical Stack
- **Platform**: iOS 17+ (SwiftUI)
- **Data**: SwiftData with @Model entities
- **Architecture**: MVVM with @Observable ViewModels
- **Calendar**: HorizonCalendar (Airbnb)
- **Navigation**: NavigationStack with tab-based structure
- **State**: Environment injection pattern

## 👥 Target Audience

### Primary Users
- **Age**: 20-45 years old
- **Profile**: Aspiring readers wanting to build consistent habits
- **Goal**: Read at least one book per month
- **Pain Points**: 
  - Difficulty maintaining reading momentum
  - Lack of visual progress feedback
  - Forgetting to track reading sessions
  - No clear reading goals

### User Personas
1. **The Busy Professional**: Wants to read more but struggles with time management
2. **The Book Club Member**: Needs to track multiple books and deadlines
3. **The Student**: Balancing required and leisure reading
4. **The Resolution Maker**: New Year goal to read more books

## 📊 Business Context

### Market Position
- **Category**: Productivity / Books
- **Competition**: Goodreads (social), Bookly (tracking), StoryGraph (recommendations)
- **Differentiation**: Focus on habit building over social features

### Success Metrics
- **Daily Active Users**: 60% of monthly actives
- **Retention**: 40% at 30 days, 25% at 90 days
- **Reading Completion**: 70% of started books get finished
- **Streak Maintenance**: Average 15-day reading streaks

### Monetization Strategy
- **Freemium Model**: Core tracking free, premium analytics and themes
- **Premium Features**: 
  - Advanced statistics and insights
  - Reading challenges and badges
  - Custom themes and icons
  - Export capabilities
  - Multiple reading goals

## 🚀 Development Priorities

### Phase 1: Core Enhancement (Current)
- Improve daily entry experience
- Enhance visual feedback
- Optimize performance

### Phase 2: Engagement Features
- Reading reminders and notifications
- Basic social sharing
- Reading challenges
- Achievement system

### Phase 3: Intelligence Layer
- Reading pace predictions
- Book recommendations
- Smart reading goals
- Time-of-day insights

### Phase 4: Community
- Reading buddies
- Book clubs
- Progress sharing
- Community challenges

## 🎨 Design Principles

### Core Values
1. **Simplicity First**: Logging pages should take < 3 seconds
2. **Visual Progress**: Make achievement tangible and beautiful
3. **Gentle Encouragement**: Motivate without pressuring
4. **Privacy Focused**: Reading habits are personal
5. **Native Feel**: Embrace iOS design patterns

### UI/UX Guidelines
- Use system colors and SF Symbols
- Respect Dynamic Type and accessibility
- Support both light and dark modes
- Optimize for one-handed use
- Provide haptic feedback for actions

## 🔧 Technical Constraints

### Platform Requirements
- iOS 17.0 minimum (SwiftData requirement)
- iPhone primary, iPad supported
- Portrait orientation focus
- Offline-first architecture

### Performance Targets
- App launch: < 1 second
- Page entry: < 500ms response
- Calendar render: < 100ms
- Stats calculation: < 200ms

### Data Limits
- Max 10,000 books per user
- Max 365 days of history displayed
- Image size: 5MB per book cover
- Sync bandwidth: Minimal (future)

## 📝 Agent Collaboration Notes

### Key Decisions Made
- SwiftData over Core Data for modern persistence
- MVVM over MVC for better separation
- HorizonCalendar for proven calendar component
- @Observable over ObservableObject for cleaner code

### Open Questions
- Social features depth vs privacy
- Gamification level (badges, levels, etc.)
- AI recommendation integration
- Cross-platform strategy (iPad, Mac, Watch)

### Technical Debt
- Need comprehensive unit tests
- Calendar performance optimization needed
- Accessibility audit required
- Localization preparation

## 🎯 Current Sprint Focus
Focus on making the daily reading entry experience delightful and frictionless. Every interaction should encourage "just one more page."

---
*Last Updated: Current Session*
*Primary Maintainer: Product Team*
*Review Cycle: Per Feature Addition*