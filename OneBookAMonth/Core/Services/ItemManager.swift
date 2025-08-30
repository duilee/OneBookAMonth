import SwiftData
import SwiftUI

class ItemManager {
    private let modelContext: ModelContext
    private var calendar: Calendar {
        return Calendar.current
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Add item
    func addItem(name: String, numberOfPages: Int) {
        let item = Item(timestamp: Date(), name: name, numberOfPages: numberOfPages)
        modelContext.insert(item)
        saveContext()
    }
    
    // Add item with image
    func addItem(name: String, numberOfPages: Int, image: UIImage?) {
        let item = Item(timestamp: Date(), name: name, numberOfPages: numberOfPages)
        if let image = image {
            item.book_image = image.pngData()
        }
        modelContext.insert(item)
        saveContext()
    }
    
    // Edit item
    func editItem(_ item: Item, name: String, numberOfPages: Int) {
        item.name = name
        item.numberOfPages = numberOfPages
        saveContext()
    }
    
    // Add delete item method
    func deleteItem(_ item: Item) {
        // Delete all associated page entries first
        for entry in item.pageEntries {
            modelContext.delete(entry)
        }
        modelContext.delete(item)
        saveContext()
    }
    
    // Delete multiple items
    func deleteItems(_ items: [Item], at offsets: IndexSet) {
        for index in offsets {
            deleteItem(items[index])
        }
    }
    
    // Update progress for a specific date
    func updateProgress(_ item: Item, pages: Int, forDate date: Date = Date()) {
        guard pages <= item.numberOfPages, pages > item.currentPage else { return }
        
        item.addPagesForDate(date, item, pages: pages)
        
        // Update currentPage to the latest progress
        if let maxPages = item.pageEntries.map({ $0.cumsumPages }).max() {
            if maxPages >= item.numberOfPages {
                item.finishedDate = date
            }
            item.currentPage = maxPages
            
        }
        
        saveContext()
    }
    
    // Get daily progress
    func getDailyProgress(_ item: Item, forDate date: Date = Date()) -> Int {
        return item.getPagesForDate(date)
    }
    
    // Check if user has updated progress today
    func hasUpdatedToday(_ item: Item) -> Bool {
        let today = Date()
        return item.pageEntries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: today)
        }
    }
    
    // Get items updated on a specific date
    func fetchItems(updatedOn date: Date) throws -> [Item] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let descriptor = FetchDescriptor<Item>(
            predicate: #Predicate<Item> { item in
                item.pageEntries.contains { entry in
                    entry.date >= startOfDay && entry.date < endOfDay
                }
            }
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    // Delete tracking data for a specific date
    func deleteTracking(_ item: Item, forDate date: Date) {
        if let entryToDelete = item.pageEntries.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
            item.pageEntries.removeAll(where: { $0 === entryToDelete })
            modelContext.delete(entryToDelete)
        }
        saveContext()
    }
    
    // MARK: - Calendar-related methods
    
    // Get dates and their counts from all items' pageEntries
    func getDateActivityCounts(for items: [Item]) -> [Date: Int] {
        return Dictionary(grouping: items.flatMap { item in
            item.pageEntries.map { entry in
                calendar.startOfDay(for: entry.date)
            }
        }) { date in
            return date
        }.mapValues { dates in
            dates.count
        }
    }
    
    // Get dates and their counts from all items' pageEntries
    func getPageEntries(for item: Item) -> [Date: Int] {
        return Dictionary(uniqueKeysWithValues: item.pageEntries.map { entry in
            // Use the start of day for consistent date keys
            let dayStart = calendar.startOfDay(for: entry.date)
            return (dayStart, entry.cumsumPages)
        })
    }
    
    // Calculate opacity based on count
    func getOpacity(for count: Int, maxCount: Int = 3, minOpacity: Double = 0.4, maxOpacity: Double = 0.7) -> Double {
        // Scale opacity between minOpacity and maxOpacity based on count
        return minOpacity + (Double(count) / Double(maxCount)) * (maxOpacity - minOpacity)
    }
    
    // Calculate date range from page entries with buffer
    func getDateRange(for items: [Item], monthBuffer: Int = 1) -> (start: Date, end: Date) {
        let allDates = items.flatMap { item in
            item.pageEntries.map { entry in
                calendar.startOfDay(for: entry.date)
            }
        }
        
        let today = Date()
        
        // If no entries, use current date ±3 months
        guard !allDates.isEmpty else {
            let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: today) ?? today
            let threeMonthsLater = calendar.date(byAdding: .month, value: 3, to: today) ?? today
            return (threeMonthsAgo, threeMonthsLater)
        }
        
        let minDate = allDates.min() ?? Date()
        let maxDate = allDates.max() ?? Date()
        
        // Add buffer of monthBuffer month(s) before and after
        let startDate = calendar.date(byAdding: .month, value: -monthBuffer, to: minDate) ?? minDate
        let endDate = calendar.date(byAdding: .month, value: monthBuffer, to: today) ?? maxDate
        
        return (startDate, endDate)
    }
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}

// MARK: - Week Heatmap Data
extension ItemManager {
    struct WeekDayData {
        let date: Date
        let dayLetter: String
        let dayNumber: Int
        let hasActivity: Bool
        let pages: Int
        let isToday: Bool
    }
    
    struct RecentMemoData {
        let memo: Memo
        let item: Item
        let coverImageData: Data?
        let hasImage: Bool
        let text: String
        let date: Date
    }
}

// Extension for analytics
extension ItemManager {
    // Get average pages read per day with days read count
    func getAveragePagesPerDay(_ item: Item) -> (average: Double, daysRead: Int) {
        // Get all page entries for the item
        let pageEntries = item.pageEntries
        
        // Group entries by date to handle multiple entries on the same day
        let entriesByDate = Dictionary(grouping: pageEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        // Count unique days with reading activity
        let daysRead = entriesByDate.count
        
        // Calculate total pages read
        let totalPages = item.currentPage
        
        // Calculate average (protect against division by zero)
        let average = daysRead > 0 ? Double(totalPages) / Double(daysRead) : 0.0
        
        return (average: average, daysRead: daysRead)
    }
    
    // Get reading streak (consecutive days)
    func getReadingStreak(_ item: Item) -> Int {
        let calendar = Calendar.current
        var currentDate = Date()
        var streak = 0
        
        while true {
            let pagesRead = item.getPagesForDate(currentDate)
            if pagesRead > 0 {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    // Get stats for a specific time period
    func getStats(for items: [Item], period: TimePeriod, selectedDate: Date = Date()) -> (totalPages: Int, books: Int, daysRead: Int, avgPages: Double) {
        let startDate: Date
        let endDate: Date
        
        switch period {
        case .day:
            // Get start of selected day
            startDate = calendar.startOfDay(for: selectedDate)
            // End date is the end of the day
            endDate = calendar.date(byAdding: .day, value: 1, to: startDate) ?? selectedDate
            
        case .week:
            // Get start of selected week (Monday)
            var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: selectedDate)
            startDate = calendar.date(from: components) ?? selectedDate
            // End date is the end of the week (Sunday)
            endDate = calendar.date(byAdding: .day, value: 7, to: startDate) ?? selectedDate
            
        case .month:
            // Get start of selected month
            var components = calendar.dateComponents([.year, .month], from: selectedDate)
            startDate = calendar.date(from: components) ?? selectedDate
            // End date is the last day of the month
            endDate = calendar.date(byAdding: DateComponents(month: 1), to: startDate) ?? selectedDate
            
        case .all:
            startDate = items.map { $0.timestamp }.min() ?? selectedDate
            endDate = Date()
        }
        
        let relevantItems = items.filter { item in
            item.pageEntries.contains { entry in
                entry.date >= startDate && entry.date < endDate && entry.pagesRead > 0
            }
        }
        
        let totalPages = relevantItems.reduce(0) { sum, item in
            let pagesInPeriod = item.pageEntries
                .filter { entry in entry.date >= startDate && entry.date < endDate }
                .reduce(0) { $0 + $1.pagesRead }
            return sum + pagesInPeriod
        }
        
        let uniqueDaysRead = Set(relevantItems.flatMap { item in
            item.pageEntries
                .filter { entry in entry.date >= startDate && entry.date < endDate && entry.pagesRead > 0 }
                .map { entry in calendar.startOfDay(for: entry.date) }
        }).count
        
        let avgPages = uniqueDaysRead > 0 ? Double(totalPages) / Double(uniqueDaysRead) : 0
        
        return (totalPages, relevantItems.count, uniqueDaysRead, avgPages)
    }
    
    func getFinishTimeline(item: Item) -> (daysLeft:Int, pagesPerDay:Int) {
        var daysLeft: Int = 0
        var pagesPerDay : Int = 0
        var daysToFinish: Int = 0
        
        let pagesLeft = item.numberOfPages - item.currentPage
        
        if item.numberOfPages > 300 {
            daysToFinish = 30
        } else if item.numberOfPages > 200 {
            daysToFinish = 20
        } else {
            daysToFinish = 10
        }
        

        pagesPerDay = Int(ceil(Double(item.numberOfPages) / Double(daysToFinish)))
        if pagesLeft < pagesPerDay {
            daysLeft = 1
            pagesPerDay = pagesLeft
        } else {
            daysLeft = Int(ceil(Double(pagesLeft) / Double(pagesPerDay)))
        }
        
        return (daysLeft, pagesPerDay)
    }
    
    // Get this week's reading data for heatmap
    func getThisWeekData(for items: [Item], selectedDate: Date = Date()) -> [WeekDayData] {
        // Get start of current week (Monday)
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start else { return [] }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E"
        
        var weekData: [WeekDayData] = []
        
        // Generate 7 days of data (Monday to Sunday)
        for dayOffset in 0..<7 {
            guard let currentDay = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) else { continue }
            
            // Calculate total pages read on this day across all items
            let dayPages = items.reduce(0) { total, item in
                total + item.getPagesReadForDate(currentDay)
            }
            
            let dayData = WeekDayData(
                date: currentDay,
                dayLetter: String(dayFormatter.string(from: currentDay).prefix(1)), // M, T, W, etc.
                dayNumber: calendar.component(.day, from: currentDay),
                hasActivity: dayPages > 0,
                pages: dayPages,
                isToday: calendar.isDate(currentDay, inSameDayAs: Date())
            )
            
            weekData.append(dayData)
        }
        
        return weekData
    }
    
    // Get recent memos from all items within last 30 days
    func getRecentMemos(for items: [Item]) -> [RecentMemoData] {
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        
        let recentMemos = items.flatMap { item in
            item.memos
                .filter { $0.date >= thirtyDaysAgo }
                .map { memo in
                    RecentMemoData(
                        memo: memo,
                        item: item,
                        coverImageData: item.book_image,
                        hasImage: memo.hasImage,
                        text: memo.text,
                        date: memo.date
                    )
                }
        }
        
        return recentMemos.sorted { $0.date > $1.date }
    }

    func saveBookImage(for item: Item, image: UIImage) {
        item.book_image = image.pngData()
        saveContext()
    }
}

// MARK: - Memo Management Extension
extension ItemManager {
    
    // MARK: - Adding Memos
    
    func addMemo(to item: Item, text: String, image: UIImage? = nil) -> Memo {
        let memo = Memo(text: text)
        
        // Set image if provided
        if let image = image {
            memo.setImage(image, itemID: item.id)
        }
        
        // Add to item's memos
        item.memos.append(memo)
        
        // Insert into context and save
        modelContext.insert(memo)
        saveContext()
        
        return memo
    }
    
    func addMemo(to item: Item, text: String, imageData: Data?) -> Memo {
        if let imageData = imageData, let image = UIImage(data: imageData) {
            return addMemo(to: item, text: text, image: image)
        } else {
            return addMemo(to: item, text: text, image: nil)
        }
    }
    
    // MARK: - Updating Memos
    
    func updateMemo(_ memo: Memo, text: String? = nil, image: UIImage? = nil, itemID: UUID) {
        // Update text if provided
        if let text = text {
            memo.text = text
        }
        
        // Update image if provided
        if let image = image {
            // Delete old image if exists
            memo.deleteImage()
            // Set new image
            memo.setImage(image, itemID: itemID)
        }
        
        saveContext()
    }
    
    func updateMemoText(_ memo: Memo, text: String) {
        memo.text = text
        saveContext()
    }
    
    func updateMemoImage(_ memo: Memo, image: UIImage?, itemID: UUID) {
        // Delete old image if exists
        memo.deleteImage()
        
        // Set new image if provided
        if let image = image {
            memo.setImage(image, itemID: itemID)
        }
        
        saveContext()
    }
    
    // MARK: - Deleting Memos
    
    func deleteMemo(_ memo: Memo, from item: Item) {
        // Delete associated image file
        memo.deleteImage()
        
        // Remove from item's memos array
        item.memos.removeAll { $0.id == memo.id }
        
        // Delete from context
        modelContext.delete(memo)
        saveContext()
    }
    
    func deleteAllMemos(from item: Item) {
        for memo in item.memos {
            memo.deleteImage()
            modelContext.delete(memo)
        }
        item.memos.removeAll()
        saveContext()
    }
    
    // MARK: - Querying Memos
    
    func getMemos(for item: Item, sortedBy: MemoSortOption = .dateDescending) -> [Memo] {
        let memos = item.memos
        
        switch sortedBy {
        case .dateAscending:
            return memos.sorted { $0.date < $1.date }
        case .dateDescending:
            return memos.sorted { $0.date > $1.date }
        case .textAlphabetical:
            return memos.sorted { $0.text.lowercased() < $1.text.lowercased() }
        }
    }
    
    func getMemosWithImages(for item: Item) -> [Memo] {
        return item.memos.filter { $0.hasImage }
    }
    
    func getMemosWithoutImages(for item: Item) -> [Memo] {
        return item.memos.filter { !$0.hasImage }
    }
    
    func getMemoCount(for item: Item) -> Int {
        return item.memos.count
    }
    
    func getMemoWithImageCount(for item: Item) -> Int {
        return item.memos.filter { $0.hasImage }.count
    }
    
    func getMemo(by id: UUID) -> Memo? {
        do {
            let descriptor = FetchDescriptor<Memo>(
                predicate: #Predicate<Memo> { memo in
                    memo.id == id
                }
            )
            return try modelContext.fetch(descriptor).first
        } catch {
            print("Error fetching memo by ID: \(error)")
            return nil
        }
    }
    
    // MARK: - Storage Management
    
    func getMemoStorageSize() -> Int64 {
        return MemoImageManager.shared.getStorageSize()
    }
    
    func getFormattedMemoStorageSize() -> String {
        return MemoImageManager.shared.formatStorageSize()
    }
    
    func cleanupOrphanedMemoImages() {
        // Get all valid memo filenames from all items
        do {
            let allItems = try getAllItems()
            let validFilenames = Set(
                allItems
                    .flatMap { $0.memos }
                    .compactMap { $0.imageFilename }
            )
            
            // Clean up orphaned files
            FileManager.default.cleanupOrphanedMemoImages(validFilenames: validFilenames)
        } catch {
            print("Error during cleanup: \(error)")
        }
    }
    
    private func getAllItems() throws -> [Item] {
        let descriptor = FetchDescriptor<Item>()
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Cache Management
    
    func preloadMemoThumbnails(for item: Item) {
        let filenames = item.memos.compactMap { $0.imageFilename }
        MemoImageManager.shared.preloadThumbnails(filenames: filenames)
    }
    
    func clearMemoImageCache() {
        MemoImageManager.shared.clearCache()
    }
}

// MARK: - Challenge Support Extension
extension ItemManager {
    
    /// Calculate total pages read within a date range for challenge progress
    func getTotalPagesReadInDateRange(for items: [Item], startDate: Date, endDate: Date) -> Int {
        return items.reduce(0) { total, item in
            let itemPages = item.pageEntries
                .filter { entry in
                    entry.date >= startDate && entry.date <= endDate && entry.pagesRead > 0
                }
                .reduce(0) { $0 + $1.pagesRead }
            return total + itemPages
        }
    }
    
    /// Get reading activity days within challenge period
    func getReadingDaysInRange(for items: [Item], startDate: Date, endDate: Date) -> Set<Date> {
        var daysWithActivity: Set<Date> = []
        
        for item in items {
            for entry in item.pageEntries {
                if entry.date >= startDate && 
                   entry.date <= endDate && 
                   entry.pagesRead > 0 {
                    daysWithActivity.insert(calendar.startOfDay(for: entry.date))
                }
            }
        }
        
        return daysWithActivity
    }
    
    /// Get daily reading data for challenge period (for charts/visualization)
    func getDailyReadingData(for items: [Item], startDate: Date, endDate: Date) -> [Date: Int] {
        var dailyData: [Date: Int] = [:]
        
        for item in items {
            for entry in item.pageEntries {
                if entry.date >= startDate && entry.date <= endDate && entry.pagesRead > 0 {
                    let dayStart = calendar.startOfDay(for: entry.date)
                    dailyData[dayStart, default: 0] += entry.pagesRead
                }
            }
        }
        
        return dailyData
    }
    
    /// Calculate reading streak within challenge period
    func getReadingStreakInRange(for items: [Item], startDate: Date, endDate: Date, from currentDate: Date = Date()) -> Int {
        var streak = 0
        var checkDate = min(currentDate, endDate)
        
        while checkDate >= startDate {
            let dayPages = items.reduce(0) { total, item in
                total + item.getPagesReadForDate(checkDate)
            }
            
            if dayPages > 0 {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate) ?? startDate
            } else {
                break
            }
        }
        
        return streak
    }
}

// MARK: - Chart Data Methods
extension ItemManager {
    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let label: String
        let date: Date
        let pages: Int
    }
    
    func getHistoricalReadingData(for items: [Item], period: TimePeriod) -> [ChartDataPoint] {
        guard !items.isEmpty else { return [] }
        
        // Get the earliest book timestamp
        let startDate = items.compactMap { $0.timestamp }.min() ?? Date()
        let endDate = Date()
        
        let fullData: [ChartDataPoint]
        switch period {
        case .week:
            fullData = aggregateByWeek(items: items, from: startDate, to: endDate)
        case .month, .all:
            fullData = aggregateByMonth(items: items, from: startDate, to: endDate)
        case .day:
            // For day view, show last 7 days
            let weekAgo = calendar.date(byAdding: .day, value: -7, to: endDate) ?? startDate
            fullData = aggregateByDay(items: items, from: weekAgo, to: endDate)
        }
        
        // Limit to most recent 15 data points
        return Array(fullData.suffix(15))
    }
    
    private func aggregateByDay(items: [Item], from startDate: Date, to endDate: Date) -> [ChartDataPoint] {
        var result: [ChartDataPoint] = []
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        
        var currentDate = calendar.startOfDay(for: startDate)
        let endDay = calendar.startOfDay(for: endDate)
        
        // Generate complete timeline (all days)
        while currentDate <= endDay {
            let dayPages = items.reduce(0) { total, item in
                total + item.getPagesForDate(currentDate)
            }
            
            let label = dayFormatter.string(from: currentDate)
            result.append(ChartDataPoint(label: label, date: currentDate, pages: dayPages))
            
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? endDay
        }
        
        return result
    }
    
    private func aggregateByWeek(items: [Item], from startDate: Date, to endDate: Date) -> [ChartDataPoint] {
        var weeklyData: [Date: Int] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        // Aggregate all page entries by week
        for item in items {
            for entry in item.pageEntries {
                // Get start of week for this entry
                guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: entry.date)?.start else { continue }
                weeklyData[weekStart, default: 0] += entry.pagesRead
            }
        }
        
        // Generate complete timeline (all weeks from start to end)
        var result: [ChartDataPoint] = []
        var currentWeek = calendar.dateInterval(of: .weekOfYear, for: startDate)?.start ?? startDate
        let endWeek = calendar.dateInterval(of: .weekOfYear, for: endDate)?.start ?? endDate
        
        // Limit to last 12 weeks to prevent overwhelming chart
        let limitedStart = max(currentWeek, calendar.date(byAdding: .weekOfYear, value: -12, to: endWeek) ?? currentWeek)
        currentWeek = limitedStart
        
        while currentWeek <= endWeek {
            let label = formatter.string(from: currentWeek)
            let pages = weeklyData[currentWeek] ?? 0 // Zero if no data
            
            result.append(ChartDataPoint(label: label, date: currentWeek, pages: pages))
            currentWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: currentWeek) ?? endWeek
        }
        
        return result
    }
    
    private func aggregateByMonth(items: [Item], from startDate: Date, to endDate: Date) -> [ChartDataPoint] {
        var monthlyData: [Date: Int] = [:]
        let formatter = DateFormatter()
        
        // Aggregate all page entries by month
        for item in items {
            for entry in item.pageEntries {
                // Get start of month for this entry
                guard let monthStart = calendar.dateInterval(of: .month, for: entry.date)?.start else { continue }
                monthlyData[monthStart, default: 0] += entry.pagesRead
            }
        }
        
        // Generate complete timeline (all months from start to end)
        var result: [ChartDataPoint] = []
        var currentMonth = calendar.dateInterval(of: .month, for: startDate)?.start ?? startDate
        let endMonth = calendar.dateInterval(of: .month, for: endDate)?.start ?? endDate
        
        // Limit to last 12 months to prevent overwhelming chart
        let limitedStart = max(currentMonth, calendar.date(byAdding: .month, value: -12, to: endMonth) ?? currentMonth)
        currentMonth = limitedStart
        
        // Format labels based on year span
        let currentYear = calendar.component(.year, from: Date())
        
        while currentMonth <= endMonth {
            let year = calendar.component(.year, from: currentMonth)
            formatter.dateFormat = year == currentYear ? "MMM" : "'yy MMM"
            let label = formatter.string(from: currentMonth)
            let pages = monthlyData[currentMonth] ?? 0 // Zero if no data
            
            result.append(ChartDataPoint(label: label, date: currentMonth, pages: pages))
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? endMonth
        }
        
        return result
    }
}

// MARK: - Memo Sort Options
enum MemoSortOption {
    case dateAscending
    case dateDescending
    case textAlphabetical
}
