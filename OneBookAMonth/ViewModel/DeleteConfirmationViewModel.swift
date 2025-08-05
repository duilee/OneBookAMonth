import SwiftUI

struct DeleteConfirmationViewModel: View {
    @Binding var isPresented: Bool
    let itemName: String
    let onConfirm: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            
            // Message
            VStack(spacing: 16) {
                Text("Are you sure you want to delete")
                    .font(.system(size: 16))
                    .foregroundColor(Color(UIColor.label))
                
                Text(itemName)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                    .multilineTextAlignment(.center)
                
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
            .padding(.top, 20)
            
            // Buttons
            HStack(spacing: 16) {
                Button(action: {
                    isPresented = false
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(red: 25/255, green: 45/255, blue: 155/255))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: {
                    onConfirm()
                    isPresented = false
                }) {
                    Text("Delete")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        //.frame(width: 320, height: 240)
        .background(Color(uiColor: .systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding(.horizontal, 48)
        //.padding(.vertical, 20)
    }
}

#Preview {
    ZStack {
        Color.gray.opacity(0.3).ignoresSafeArea()
        DeleteConfirmationViewModel(
            isPresented: .constant(true),
            itemName: "The Great Gatsby",
            onConfirm: {}
        )
    }
} 
