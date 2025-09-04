import SwiftUI
import SwiftData

struct AddBookStepView: View {
    @Environment(\.modelContext) private var modelContext
    let viewModel: OnboardingViewModel
    
    let onNext: () -> Void
    let onSkip: () -> Void
    
    @State private var bookTitle = ""
    @State private var numberOfPages = ""
    @State private var hasAddedBook = false
    @State private var itemManager: ItemManager?
    @Query private var items: [Item]
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, pages
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "book.fill")
                .font(.system(size: 80))
                .foregroundStyle(.tint)
            
            VStack(spacing: 16) {
                Text("Add Your First Book")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Start tracking your reading journey")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            if !hasAddedBook {
                VStack(spacing: 16) {
                    TextField("Book Title", text: $bookTitle)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                        .submitLabel(.next)
                        .focused($focusedField, equals: .title)
                        .onSubmit {
                            focusedField = .pages
                        }
                    
                    TextField("Total Pages", text: $numberOfPages)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.numberPad)
                        .submitLabel(.done)
                        .focused($focusedField, equals: .pages)
                        .onSubmit {
                            if isValidInput {
                                addBook()
                            }
                        }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 40)
            } else if let addedBook = viewModel.addedBook {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.green)
                    
                    Text(addedBook.name)
                        .font(.headline)
                    
                    Text("\(addedBook.numberOfPages) pages")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Great choice!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 40)
            }
            
            Spacer()
            
            VStack(spacing: 16) {
                if !hasAddedBook {
                    Button(action: addBook) {
                        Text("Add This Book")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isValidInput ? Color.accentColor : Color.gray)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(!isValidInput)
                } else {
                    Button(action: onNext) {
                        Text("Continue")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .padding()
        .onTapGesture {
            focusedField = nil
        }
        .onAppear {
            if itemManager == nil {
                itemManager = ItemManager(modelContext: modelContext)
            }
            if let firstBook = items.first {
                viewModel.addedBook = firstBook
                hasAddedBook = true
            }
        }
    }
    
    private var isValidInput: Bool {
        !bookTitle.isEmpty && Int(numberOfPages) != nil && Int(numberOfPages) ?? 0 > 0
    }
    
    private func addBook() {
        guard let pages = Int(numberOfPages),
              !bookTitle.isEmpty else { return }
        
        // Dismiss keyboard
        focusedField = nil
        
        // Create and insert the book directly
        let newItem = Item(timestamp: Date(), name: bookTitle, numberOfPages: pages)
        modelContext.insert(newItem)
        
        do {
            try modelContext.save()
            viewModel.addedBook = newItem
            withAnimation {
                hasAddedBook = true
            }
        } catch {
            print("Failed to save book: \(error)")
        }
    }
}
