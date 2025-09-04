import SwiftUI

struct WelcomeStepView: View {
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            Image(systemName: "books.vertical.fill")
                .font(.system(size: 100))
                .foregroundStyle(.tint)
            
            VStack(spacing: 16) {
                Text("One Book A Month")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Build lasting reading habits,\none page at a time")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button(action: onNext) {
                Text("Get Started")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .padding()
    }
}
