import SwiftUI
import Charts

// MARK: - Models

struct ReadingDay {
    let day: Int
    let pages: Int
    let minutes: Int
    
    var hasReading: Bool {
        return pages > 0
    }
    
    var metGoal: Bool {
        return pages >= 30
    }
}

struct Book {
    let title: String
    let totalPages: Int
    let currentPage: Int
    
    var percentComplete: Double {
        return Double(currentPage) / Double(totalPages)
    }
}

// MARK: - Main View

struct ReadingAppView: View {
    @State private var activeView: ActiveView = .activity
    @State private var timeframe: Timeframe = .month
    
    enum ActiveView {
        case activity, calendar
    }
    
    enum Timeframe: String, CaseIterable {
        case week = "W"
        case month = "M"
        case year = "Y"
        case all = "All"
    }
    
    // Sample data
    let currentMonth = "March 2025"
    let totalPages = 1284
    let booksCompleted = 3
    let readingTime = "42:15:30"
    let readingStreak = 18
    
    // Current book
    let currentBook = Book(title: "The Great Gatsby", totalPages: 200, currentPage: 84)
    
    // Reading activity data
    let readingActivity: [ReadingDay] = [
        ReadingDay(day: 1, pages: 42, minutes: 35),
        ReadingDay(day: 2, pages: 38, minutes: 30),
        ReadingDay(day: 3, pages: 0, minutes: 0),
        ReadingDay(day: 4, pages: 65, minutes: 45),
        ReadingDay(day: 5, pages: 50, minutes: 40),
        ReadingDay(day: 6, pages: 0, minutes: 0),
        ReadingDay(day: 7, pages: 30, minutes: 25),
        ReadingDay(day: 8, pages: 45, minutes: 35),
        ReadingDay(day: 9, pages: 60, minutes: 50),
        ReadingDay(day: 10, pages: 55, minutes: 45),
        ReadingDay(day: 11, pages: 0, minutes: 0),
        ReadingDay(day: 12, pages: 0, minutes: 0),
        ReadingDay(day: 13, pages: 70, minutes: 60),
        ReadingDay(day: 14, pages: 65, minutes: 55),
        ReadingDay(day: 15, pages: 40, minutes: 35),
        ReadingDay(day: 16, pages: 35, minutes: 30),
        ReadingDay(day: 17, pages: 0, minutes: 0),
        ReadingDay(day: 18, pages: 50, minutes: 40),
        ReadingDay(day: 19, pages: 55, minutes: 45),
        ReadingDay(day: 20, pages: 60, minutes: 50),
        ReadingDay(day: 21, pages: 45, minutes: 35),
        ReadingDay(day: 22, pages: 0, minutes: 0),
        ReadingDay(day: 23, pages: 75, minutes: 65),
        ReadingDay(day: 24, pages: 0, minutes: 0),
        ReadingDay(day: 25, pages: 0, minutes: 0),
        ReadingDay(day: 26, pages: 0, minutes: 0),
        ReadingDay(day: 27, pages: 0, minutes: 0),
        ReadingDay(day: 28, pages: 0, minutes: 0),
        ReadingDay(day: 29, pages: 0, minutes: 0),
        ReadingDay(day: 30, pages: 0, minutes: 0),
        ReadingDay(day: 31, pages: 0, minutes: 0)
    ]
    
    // Computed properties
    var maxPages: Int {
        return readingActivity.map { $0.pages }.max() ?? 0
    }
    
    var readingDays: Int {
        return readingActivity.filter { $0.hasReading }.count
    }
    
    var avgPagesPerDay: Int {
        return readingDays > 0 ? totalPages / readingDays : 0
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Circle()
                            .fill(Color(.systemGray5))
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("DL")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                            )
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Image(systemName: "trophy")
                                .font(.system(size: 20))
                                .foregroundColor(.primary)
                                .frame(width: 40, height: 40)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            // Title and View Toggle
                            HStack {
                                Text("Activity")
                                    .font(.system(size: 28, weight: .bold))
                                
                                Spacer()
                                
                                // View Toggle
                                Picker("View", selection: $activeView) {
                                    HStack {
                                        Image(systemName: "chart.bar")
                                        Text("Stats")
                                    }.tag(ActiveView.activity)
                                    
                                    HStack {
                                        Image(systemName: "calendar")
                                        Text("Calendar")
                                    }.tag(ActiveView.calendar)
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .frame(width: 180)
                            }
                            
                            // Time Period Selector
                            Picker("Timeframe", selection: $timeframe) {
                                ForEach(Timeframe.allCases, id: \.self) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.vertical, 8)
                            
                            // Month Selector
                            Button(action: {}) {
                                HStack {
                                    Text(currentMonth)
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14, weight: .medium))
                                }
                                .padding(.vertical, 8)
                            }
                            .foregroundColor(.primary)
                            
                            // Main Stats
                            VStack(spacing: 8) {
                                Text("\(totalPages)")
                                    .font(.system(size: 80, weight: .black))
                                    .minimumScaleFactor(0.5)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                
                                Text("Pages")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.bottom, 16)
                                
                                HStack(spacing: 0) {
                                    StatView(value: "\(booksCompleted)", label: "Books")
                                    StatView(value: "\(avgPagesPerDay)", label: "Avg. Pages")
                                    StatView(value: "\(readingTime.split(separator: ":")[0])h", label: "Time")
                                }
                            }
                            .padding(.bottom, 16)
                            
                            // Activity View
                            if activeView == .activity {
                                ActivityView(
                                    readingActivity: readingActivity,
                                    maxPages: maxPages,
                                    avgPagesPerDay: avgPagesPerDay,
                                    readingDays: readingDays
                                )
                            }
                            
                            // Calendar View
                            if activeView == .calendar {
                                CalendarView(
                                    readingActivity: readingActivity,
                                    readingDays: readingDays,
                                    readingStreak: readingStreak
                                )
                            }
                            
                            // Current Reading
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Currently Reading")
                                    .font(.system(size: 18, weight: .semibold))
                                
                                CurrentBookView(book: currentBook)
                                CurrentBookView(book: currentBook)
                            }
                            
                            // Reading Streak
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: "trophy")
                                        .font(.system(size: 18))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Current Streak: \(readingStreak) days")
                                        .font(.system(size: 16, weight: .medium))
                                    
                                    Text("Keep it up! You're building a great habit.")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            
                            // Did you read today? - Only show if on calendar view
                            if activeView == .calendar {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Did you read today?")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(.blue)
                                    
                                    Button(action: {}) {
                                        HStack {
                                            Text("Log today's reading")
                                                .font(.system(size: 16, weight: .medium))
                                            
                                            Spacer()
                                            
                                            Image(systemName: "arrow.right")
                                        }
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                    }
                                }
                                .padding()
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Tab Bar
                    TabBar()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Activity View

struct ActivityView: View {
    let readingActivity: [ReadingDay]
    let maxPages: Int
    let avgPagesPerDay: Int
    let readingDays: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Chart Header
            HStack {
                Text("Daily Reading Activity")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
                
                Spacer()
                
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        
                        Text("Pages")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 4) {
                        Rectangle()
                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 1, dash: [2]))
                            .frame(width: 8, height: 8)
                        
                        Text("Goal")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
            
            // Chart
            ZStack(alignment: .leading) {
                // Goal line
                HStack {
                    Text("30")
                        .font(.system(size: 10))
                        .foregroundColor(.blue)
                        .frame(width: 20, alignment: .trailing)
                    
                    Rectangle()
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .frame(height: 1)
                }
                .offset(y: -60)
                
                // Average line
                HStack {
                    Text("\(avgPagesPerDay)")
                        .font(.system(size: 10))
                        .foregroundColor(.purple)
                        .frame(width: 20, alignment: .trailing)
                    
                    Rectangle()
                        .stroke(Color.purple, style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .frame(height: 1)
                }
                .offset(y: -90)
                
                // Y-axis labels
                VStack(alignment: .trailing, spacing: 0) {
                    Text("\(maxPages)")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(maxPages/2)")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("0")
                        .font(.system(size: 10))
                        .foregroundColor(.gray)
                }
                .frame(width: 20, height: 150)
                
                // Chart bars
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(0..<readingActivity.count, id: \.self) { index in
                        let day = readingActivity[index]
                        let isToday = index == 22 // Day 23
                        
                        VStack(spacing: 2) {
                            if day.pages > 0 {
                                Rectangle()
                                    .fill(isToday ? Color.blue : (day.metGoal ? Color.green : Color.green.opacity(0.7)))
                                    .frame(width: isToday ? 4 : 3, height: CGFloat(day.pages) / CGFloat(maxPages) * 150)
                                    .cornerRadius(2)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 3, height: 2)
                                    .cornerRadius(1)
                            }
                            
                            if index == 0 || index == 7 || index == 14 || index == 22 || index == 30 {
                                Text("\(day.day)")
                                    .font(.system(size: 10))
                                    .foregroundColor(.gray)
                                    .padding(.top, 4)
                            } else {
                                Spacer()
                                    .frame(height: 14)
                            }
                        }
                    }
                }
                .padding(.leading, 24)
            }
            .frame(height: 180)
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            
            // Reading insights
            HStack(spacing: 12) {
                // Longest streak
                VStack(alignment: .leading, spacing: 4) {
                    Text("Longest streak")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("7 days")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("Mar 13-19")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                // Best reading day
                VStack(alignment: .leading, spacing: 4) {
                    Text("Best reading day")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("75 pages")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Mar 23 (Today)")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Monthly consistency
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("This month")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("\(readingDays) reading days")
                        .font(.system(size: 16, weight: .medium))
                }
                
                HStack(spacing: 8) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(.systemGray5))
                                .frame(height: 8)
                                .cornerRadius(4)
                            
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: CGFloat(readingDays) / 31.0 * geometry.size.width, height: 8)
                                .cornerRadius(4)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(Int(Double(readingDays) / 31.0 * 100))%")
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Calendar View

struct CalendarView: View {
    let readingActivity: [ReadingDay]
    let readingDays: Int
    let readingStreak: Int
    let weekDays = ["S", "M", "T", "W", "T", "F", "S"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Calendar
            VStack(spacing: 8) {
                // Weekday headers
                HStack {
                    ForEach(weekDays, id: \.self) { day in
                        Text(day)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                    }
                }
                
                // Calendar grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                    // Empty cells for days before the 1st (assuming March 2025 starts on a Thursday)
                    ForEach(0..<3, id: \.self) { _ in
                        Color.clear
                            .frame(height: 40)
                    }
                    
                    // Actual days
                    ForEach(0..<readingActivity.count, id: \.self) { index in
                        let day = readingActivity[index]
                        let isToday = index == 22 // Day 23
                        
                        ZStack {
                            Circle()
                                .fill(day.hasReading ? (day.metGoal ? Color.green : Color.green.opacity(0.3)) : Color.clear)
                                .frame(width: 36, height: 36)
                            
                            if isToday {
                                Circle()
                                    .stroke(Color.blue, lineWidth: 2)
                                    .frame(width: 38, height: 38)
                            }
                            
                            Text("\(day.day)")
                                .font(.system(size: 14, weight: day.hasReading ? .medium : .regular))
                                .foregroundColor(day.hasReading ? (day.metGoal ? .white : .green) : .primary)
                            
                            if day.hasReading {
                                Text("\(day.pages)")
                                    .font(.system(size: 8, weight: .medium))
                                    .padding(.horizontal, 4)
                                    .background(Color.white)
                                    .cornerRadius(4)
                                    .offset(y: 20)
                            }
                        }
                        .frame(height: 40)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
            
            // Calendar stats
            HStack(spacing: 12) {
                // Reading days
                VStack(alignment: .leading, spacing: 4) {
                    Text("Reading days")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("\(readingDays)/31")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.green)
                    
                    Text("\(Int(Double(readingDays) / 31.0 * 100))% of month")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.green.opacity(0.1))
                .cornerRadius(12)
                
                // Current streak
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current streak")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("\(readingStreak) days")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.blue)
                    
                    Text("Keep it up!")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
            }
            
            // Monthly consistency
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Monthly consistency")
                        .font(.system(size: 14, weight: .medium))
                    
                    Spacer()
                    
                    Text("\(Int(Double(readingDays) / 31.0 * 100))%")
                        .font(.system(size: 14, weight: .medium))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 8)
                            .cornerRadius(4)
                        
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: CGFloat(readingDays) / 31.0 * geometry.size.width, height: 8)
                            .cornerRadius(4)
                    }
                }
                .frame(height: 8)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Supporting Views

struct StatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
            
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CurrentBookView: View {
    let book: Book
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Rectangle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 48, height: 64)
                    .cornerRadius(6)
                
                Image(systemName: "book")
                    .font(.system(size: 24))
                    .foregroundColor(.blue)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(book.title)
                    .font(.system(size: 16, weight: .medium))
                
                HStack {
                    Text("\(Int(book.percentComplete * 100))% complete")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("•")
                        .foregroundColor(.gray)
                    
                    Text("\(book.currentPage) of \(book.totalPages) pages")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .fill(Color(.systemGray5))
                            .frame(height: 6)
                            .cornerRadius(3)
                        
                        Rectangle()
                            .fill(Color.blue)
                            .frame(width: CGFloat(book.percentComplete) * geometry.size.width, height: 6)
                            .cornerRadius(3)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct TabBar: View {
    var body: some View {
        HStack {
            TabBarButton(icon: "house.fill", label: "Home", isSelected: true)
            TabBarButton(icon: "book", label: "Library", isSelected: false)
            TabBarButton(icon: "chart.bar", label: "Stats", isSelected: false)
            TabBarButton(icon: "checkmark.circle", label: "Goals", isSelected: false)
            TabBarButton(icon: "person", label: "Profile", isSelected: false)
        }
        .padding(.top, 8)
        .padding(.bottom, 8 + (UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0))
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.systemGray4)),
            alignment: .top
        )
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(isSelected ? .blue : .gray)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(isSelected ? .blue : .gray)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Preview

struct ReadingAppView_Previews: PreviewProvider {
    static var previews: some View {
        ReadingAppView()
    }
}


//
//ScrollView {
//    LazyVStack {
//        ForEach(items) { item in
//            ItemRow(item: item)
//        }
//    }
//    .padding()
//}
