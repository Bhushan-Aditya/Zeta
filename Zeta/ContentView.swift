import SwiftUI

struct ContentView: View {
    @State private var onboardingComplete = false

    var body: some View {
        NavigationStack {
            if onboardingComplete {
                WelcomeView() // Show WelcomeView if onboarding is complete
            } else {
                OnboardingView(onboardingComplete: $onboardingComplete) // Show OnboardingView initially
            }
        }
    }
}

#Preview {
    ContentView()
}
