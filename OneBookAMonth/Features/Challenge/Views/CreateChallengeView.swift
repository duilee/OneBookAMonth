//
//  CreateChallengeView.swift
//  OneBookAMonth
//
//  Created by Claude on 2025-08-31.
//

import SwiftUI

struct CreateChallengeView: View {
    @Binding var isPresented: Bool
    let viewModel: ChallengeViewModel
    
    @State private var challengeName: String = "My Reading Challenge"
    @State private var startDate = Calendar.current.startOfDay(for: Date())
    @State private var endDate = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: 29, to: Date()) ?? Date())
    @State private var targetPages: String = "300"
    @State private var showError = false
    @State private var errorMessage = ""
    
    private let primaryColor = Color(red: 25/255, green: 45/255, blue: 155/255)
    
    private var duration: Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return max(1, (components.day ?? 0) + 1)
    }
    
    private var dailyPagesNeeded: Int {
        guard let pages = Int(targetPages), pages > 0 else { return 0 }
        return Int(ceil(Double(pages) / Double(duration)))
    }
    
    private var isFormValid: Bool {
        !challengeName.isEmpty && 
        Int(targetPages) != nil && 
        Int(targetPages)! > 0 &&
        endDate > startDate
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header illustration
                    VStack(spacing: 12) {
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 60))
                            .foregroundColor(primaryColor)
                        
                        Text("Create a Reading Challenge")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("Set a goal and track your reading progress")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Form fields
                    VStack(spacing: 20) {
                        // Challenge Name
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Challenge Name", systemImage: "pencil")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            TextField("e.g., Summer Reading Challenge", text: $challengeName)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Duration Section
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Duration", systemImage: "clock")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            // Quick Duration Options
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    DurationChip(label: "1 Week", days: 7, startDate: startDate, endDate: $endDate)
                                    DurationChip(label: "2 Weeks", days: 14, startDate: startDate, endDate: $endDate)
                                    DurationChip(label: "1 Month", days: 30, startDate: startDate, endDate: $endDate)
                                }
                            }
                            
                            // Date Selection
                            HStack(spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Start Date")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    DatePicker("", selection: $startDate, displayedComponents: .date)
                                        .labelsHidden()
                                        .datePickerStyle(.compact)
                                        .frame(maxWidth: .infinity)
                                        .padding(12)
                                        .background(
                                            RoundedRectangle(cornerRadius: 10)
                                                .fill(Color.gray.opacity(0.1))
                                        )
                                }
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("End Date")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.secondary)
                                    
                                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .frame(maxWidth: .infinity)
                                    .padding(12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color.gray.opacity(0.1))
                                    )
                                }
                            }
                        }
                        
                        // Target Pages
                        VStack(alignment: .leading, spacing: 12) {
                            Label("Target Pages", systemImage: "book.pages")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            // Quick Pages Options
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    PagesChip(label: "100 pages", pages: 100, targetPages: $targetPages)
                                    PagesChip(label: "200 pages", pages: 200, targetPages: $targetPages)
                                    PagesChip(label: "300 pages", pages: 300, targetPages: $targetPages)
                                }
                            }
                            
                            TextField("Enter target pages", text: $targetPages)
                                .keyboardType(.numberPad)
                                .textFieldStyle(CustomTextFieldStyle())
                        }
                        
                        // Challenge Summary Card
                        if isFormValid {
                            VStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(primaryColor)
                                    Text("Challenge Summary")
                                        .font(.system(size: 16, weight: .semibold))
                                    Spacer()
                                }
                                
                                VStack(spacing: 8) {
                                    SummaryRow(label: "Duration", value: "\(duration) days")
                                    SummaryRow(label: "Daily Goal", value: "\(dailyPagesNeeded) pages/day")
                                    SummaryRow(label: "Total Pages", value: "\(targetPages) pages")
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(primaryColor.opacity(0.1))
                            )
                            .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createChallenge()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .disabled(!isFormValid)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func createChallenge() {
        guard let pages = Int(targetPages) else { return }
        
        // Ensure dates are at start of day for consistent calculation
        let calendar = Calendar.current
        let normalizedStartDate = calendar.startOfDay(for: startDate)
        let normalizedEndDate = calendar.startOfDay(for: endDate)
        
        let success = viewModel.createChallenge(
            name: challengeName,
            startDate: normalizedStartDate,
            endDate: normalizedEndDate,
            targetPages: pages
        )
        
        if success {
            isPresented = false
        } else {
            errorMessage = viewModel.errorMessage ?? "Failed to create challenge"
            showError = true
        }
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
            )
    }
}

struct SummaryRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Chip Components

struct DurationChip: View {
    let label: String
    let days: Int?
    let startDate: Date
    @Binding var endDate: Date
    
    private var isSelected: Bool {
        guard let days = days else { return false }
        let calendar = Calendar.current
        let expectedEnd = calendar.date(byAdding: .day, value: days - 1, to: startDate) ?? startDate
        return calendar.isDate(endDate, inSameDayAs: expectedEnd)
    }
    
    var body: some View {
        Button(action: {
            if let days = days {
                endDate = Calendar.current.date(byAdding: .day, value: days - 1, to: startDate) ?? startDate
            }
        }) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(red: 25/255, green: 45/255, blue: 155/255) : Color.gray.opacity(0.1))
                )
                .foregroundColor(isSelected ? .white : Color(red: 25/255, green: 45/255, blue: 155/255))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PagesChip: View {
    let label: String
    let pages: Int?
    @Binding var targetPages: String
    
    private var isSelected: Bool {
        guard let pages = pages else { return false }
        return targetPages == String(pages)
    }
    
    var body: some View {
        Button(action: {
            if let pages = pages {
                targetPages = String(pages)
            }
        }) {
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? Color(red: 25/255, green: 45/255, blue: 155/255) : Color.gray.opacity(0.1))
                )
                .foregroundColor(isSelected ? .white : Color(red: 25/255, green: 45/255, blue: 155/255))
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    CreateChallengeView(
        isPresented: .constant(true),
        viewModel: ChallengeViewModel()
    )
}
