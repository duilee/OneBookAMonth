//
//  CreateChallengeView.swift
//  OneBookAMonth
//
//  Created by delightroom on 3/30/25.
//

import SwiftUI
import SwiftData

struct CreateChallengeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var challengeName = ""
    @State private var targetPages = ""
    @State private var selectedDuration = ChallengeDuration.month
    @State private var startDate = Date()
    @State private var showValidationAlert = false
    @State private var validationMessage = ""
    @State private var isSaving = false
    @State private var challengeManager: ChallengeManager?
    
    private var endDate: Date {
        switch selectedDuration {
        case .week:
            return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate) ?? startDate
        case .twoWeeks:
            return Calendar.current.date(byAdding: .weekOfYear, value: 2, to: startDate) ?? startDate
        case .month:
            return Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        case .twoMonths:
            return Calendar.current.date(byAdding: .month, value: 2, to: startDate) ?? startDate
        case .custom:
            return Calendar.current.date(byAdding: .month, value: 1, to: startDate) ?? startDate
        }
    }
    
    private var canSave: Bool {
        !challengeName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !targetPages.isEmpty &&
        Int(targetPages) != nil &&
        Int(targetPages) ?? 0 > 0
    }
    
    private var dailyPagesNeeded: Int {
        guard let pages = Int(targetPages) else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 1
        return max(1, Int(ceil(Double(pages) / Double(days))))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    
                    // Challenge Name Section
                    challengeNameSection
                    
                    // Target Pages Section
                    targetPagesSection
                    
                    // Duration Section
                    durationSection
                    
                    // Date Range Section
                    dateRangeSection
                    
                    // Preview Section
                    challengePreviewSection
                    
                    Spacer(minLength: 60)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("New Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createChallenge()
                    }
                    .disabled(!canSave || isSaving)
                    .fontWeight(.semibold)
                }
            }
        }
        .alert("Invalid Challenge", isPresented: $showValidationAlert) {
            Button("OK") { }
        } message: {
            Text(validationMessage)
        }
        .onAppear {
            if challengeManager == nil {
                challengeManager = ChallengeManager(modelContext: modelContext)
            }
        }
    }
    
    // MARK: - View Components
    
    private var challengeNameSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("Challenge Name")
                    .font(.system(size: 18, weight: .semibold))
            } icon: {
                Image(systemName: "target")
                    .font(.system(size: 16))
                    .foregroundColor(ColorPalette().deep)
            }
            
            TextField("e.g., March Reading Challenge", text: $challengeName)
                .textFieldStyle(.roundedBorder)
                .font(.system(size: 16))
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
    }
    
    private var targetPagesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("Target Pages")
                    .font(.system(size: 18, weight: .semibold))
            } icon: {
                Image(systemName: "book.pages")
                    .font(.system(size: 16))
                    .foregroundColor(ColorPalette().deep)
            }
            
            HStack {
                TextField("1000", text: $targetPages)
                    .textFieldStyle(.roundedBorder)
                    .font(.system(size: 16))
                    .keyboardType(.numberPad)
                
                Text("pages")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
            }
            
            // Quick preset buttons
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 8) {
                ForEach([300, 500, 750, 1000], id: \.self) { pages in
                    Button(action: {
                        targetPages = "\(pages)"
                    }) {
                        Text("\(pages)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(targetPages == "\(pages)" ? .white : ColorPalette().deep)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(targetPages == "\(pages)" ? ColorPalette().deep : Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
    }
    
    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("Duration")
                    .font(.system(size: 18, weight: .semibold))
            } icon: {
                Image(systemName: "calendar")
                    .font(.system(size: 16))
                    .foregroundColor(ColorPalette().deep)
            }
            
            Picker("Duration", selection: $selectedDuration) {
                ForEach(ChallengeDuration.allCases, id: \.self) { duration in
                    Text(duration.displayName)
                        .tag(duration)
                }
            }
            .pickerStyle(.segmented)
            
            HStack {
                Image(systemName: "info.circle")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Text(selectedDuration.description)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
    }
    
    private var dateRangeSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("Start Date")
                    .font(.system(size: 18, weight: .semibold))
            } icon: {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 16))
                    .foregroundColor(ColorPalette().deep)
            }
            
            DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .font(.system(size: 16))
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Start Date")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(startDate, format: .dateTime.month(.wide).day().year())
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("End Date")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(endDate, format: .dateTime.month(.wide).day().year())
                        .font(.system(size: 14))
                        .foregroundColor(.primary)
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
    }
    
    private var challengePreviewSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label {
                Text("Challenge Preview")
                    .font(.system(size: 18, weight: .semibold))
            } icon: {
                Image(systemName: "eye")
                    .font(.system(size: 16))
                    .foregroundColor(ColorPalette().deep)
            }
            
            VStack(spacing: 12) {
                // Challenge name
                if !challengeName.isEmpty {
                    HStack {
                        Text("Name:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(challengeName)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                // Target pages
                if let pages = Int(targetPages), pages > 0 {
                    HStack {
                        Text("Target:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(pages) pages")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                }
                
                // Daily average
                if Int(targetPages) != nil {
                    HStack {
                        Text("Daily Goal:")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(dailyPagesNeeded) pages/day")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(dailyPagesNeeded > 50 ? .orange : ColorPalette().deep)
                    }
                }
                
                // Duration
                let totalDays = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
                HStack {
                    Text("Duration:")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(totalDays) days")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
            .padding(.vertical, 8)
        }
        .padding(20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
    }
    
    // MARK: - Actions
    
    private func createChallenge() {
        guard canSave else { return }
        
        guard let pages = Int(targetPages), pages > 0 else {
            validationMessage = "Please enter a valid number of pages greater than 0."
            showValidationAlert = true
            return
        }
        
        guard let manager = challengeManager else {
            validationMessage = "Challenge manager not available. Please try again."
            showValidationAlert = true
            return
        }
        
        isSaving = true
        
        Task {
            do {
                // Check if there's already an active challenge (moved to background)
                let existingChallenge = manager.getActiveChallenge()
                if existingChallenge != nil {
                    await MainActor.run {
                        isSaving = false
                        validationMessage = "You already have an active challenge. Complete or cancel it before creating a new one."
                        showValidationAlert = true
                    }
                    return
                }
                
                // Create the challenge
                let name = challengeName.trimmingCharacters(in: .whitespacesAndNewlines)
                let _ = try manager.createChallenge(
                    name: name,
                    targetPages: pages,
                    startDate: startDate,
                    endDate: endDate
                )
                
                await MainActor.run {
                    isSaving = false
                    dismiss()
                }
                
            } catch {
                await MainActor.run {
                    isSaving = false
                    validationMessage = "Failed to create challenge. Please try again."
                    showValidationAlert = true
                }
                print("Error creating challenge: \(error)")
            }
        }
    }
}

// MARK: - Supporting Types

enum ChallengeDuration: String, CaseIterable {
    case week = "1W"
    case twoWeeks = "2W"
    case month = "1M"
    case twoMonths = "2M"
    case custom = "Custom"
    
    var displayName: String {
        switch self {
        case .week:
            return "1 Week"
        case .twoWeeks:
            return "2 Weeks"
        case .month:
            return "1 Month"
        case .twoMonths:
            return "2 Months"
        case .custom:
            return "Custom"
        }
    }
    
    var description: String {
        switch self {
        case .week:
            return "Perfect for quick reading sprints"
        case .twoWeeks:
            return "Balanced challenge duration"
        case .month:
            return "Most popular challenge length"
        case .twoMonths:
            return "For ambitious reading goals"
        case .custom:
            return "Set your own timeline"
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Item.self, Challenge.self, PageEntry.self, Memo.self, configurations: config)
    
    return CreateChallengeView()
        .modelContainer(container)
}