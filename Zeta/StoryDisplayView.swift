import SwiftUI

struct StoryDisplayView: View {
    let storyText: String
    let isLoading: Bool
    let onDone: () -> Void
    
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            // Consistent Background
            LinearGradient(gradient: Gradient(colors: [Color.zetaBackgroundGradientStart, Color.zetaBackgroundGradientEnd]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            GeometryReader { geometry in
                StarfieldView(geometry: geometry, dragOffset: .constant(.zero))
            }
            
            VStack(spacing: 30) {
                Text("Your Story Awaits...")
                    .font(.custom("Avenir-Heavy", size: 28))
                    .foregroundStyle(Color.welcomeViewTextPrimary)
                    .padding(.top, 60)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(2.0)
                    Text("Dreaming up your tale...")
                        .font(.custom("Avenir-Medium", size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top)
                    Spacer()
                } else {
                    ScrollView {
                        Text(storyText)
                            .font(.custom("Avenir-Medium", size: 20))
                            .lineSpacing(8)
                            .foregroundStyle(.white.opacity(0.9))
                            .padding(25)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.black.opacity(0.2))
                            )
                            .padding(.horizontal)
                    }
                }
                
                Button(action: onDone) {
                    Text("All Done!")
                        .font(.custom("Avenir-Heavy", size: 19))
                        .frame(width: 270, height: 56)
                        .foregroundStyle(.white)
                        .background(
                            Capsule().fill(LinearGradient(colors: [.blue, .purple.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
                        )
                }
                .padding(.bottom, 40)
                .opacity(isLoading ? 0 : 1) // Hide button while loading
            }
            .opacity(showContent ? 1 : 0)
            .animation(.easeInOut(duration: 0.8), value: showContent)
            .onAppear { showContent = true }
        }
    }
}
