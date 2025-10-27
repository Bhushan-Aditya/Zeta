// OnboardingView.swift
// Located in: Zeta/Zeta/Onboarding/OnboardingView.swift

import SwiftUI

struct OnboardingView: View {
    @Binding var onboardingComplete: Bool // Binding to signal completion to the parent view (e.g., ContentView or ZetaApp)
    
    // Animation states for the logo and background
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.7 // Start smaller for a zoom-in effect
    @State private var backgroundOpacity: Double = 0 // Start transparent for fade-in

    // Total duration for this screen before automatically proceeding
    private let screenDuration: Double = 3.0 // e.g., 3 seconds total
    private let animationInDuration: Double = 1.2 // Duration for logo and background to animate in
    private let fadeOutDelay: Double = 0.3 // Short delay before fading out elements (optional)

    var body: some View {
        ZStack {
            // Background gradient - Uses global static colors
            // Ensure Color.zetaBackgroundGradientStart and Color.zetaBackgroundGradientEnd
            // are defined in your ColorExtensions.swift file.
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.zetaBackgroundGradientStart,
                    Color.zetaBackgroundGradientEnd
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .opacity(backgroundOpacity) // Animate the opacity for a smooth fade-in

            // App logo centered
            // Ensure "ZetaLogo" is an image asset in your Assets.xcassets
            Image("ZetaLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 250) // Adjust size as needed for your logo
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
        }
        .onAppear {
            // Animate the background opacity to fade in
            withAnimation(.easeIn(duration: animationInDuration * 0.7)) { // Faster background fade
                backgroundOpacity = 1
            }
            
            // Animate the logo's scale and opacity to "pop" in
            // Using a spring animation for a slightly more dynamic feel
            withAnimation(.interpolatingSpring(stiffness: 100, damping: 12).delay(animationInDuration * 0.2)) { // Slight delay for logo
                logoOpacity = 1
                logoScale = 1 // Scale to full size
            }

            // Calculate when to start fading out elements before navigation
            let fadeOutStartTime = screenDuration - (animationInDuration * 0.5) - fadeOutDelay

            // Schedule fade-out animation (optional, for a smoother transition away)
            DispatchQueue.main.asyncAfter(deadline: .now() + fadeOutStartTime) {
                withAnimation(.easeOut(duration: animationInDuration * 0.5)) {
                    logoOpacity = 0
                    // You could also fade out the background here if desired
                    // backgroundOpacity = 0
                }
            }

            // Schedule the completion signal
            DispatchQueue.main.asyncAfter(deadline: .now() + screenDuration) {
                // Ensure we are on the main thread for UI updates
                onboardingComplete = true
            }
        }
    }
}

// Preview Provider
struct OnboardingView_Previews: PreviewProvider {
    // A helper struct to provide the @State binding for the preview
    struct PreviewHost: View {
        @State private var isComplete = false
        var body: some View {
            OnboardingView(onboardingComplete: $isComplete)
        }
    }

    static var previews: some View {
        PreviewHost()
    }
}
