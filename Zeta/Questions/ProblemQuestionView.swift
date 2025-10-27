import SwiftUI

// MARK: - ProblemQuestionView (Corrected)

struct ProblemQuestionView: View {
    // --- State & Bindings ---
    @Binding var storyElements: StoryElements
    let onNext: () -> Void
    let onBack: () -> Void

    // Internal state for this view
    @State private var selectedChallenge: ChallengeType?
    @State private var parallaxDragOffset: CGSize = .zero
    
    // Animation state
    @State private var showContent = false
    @State private var continueButtonScale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // --- Reusing Background Elements for Consistency ---
                LinearGradient(gradient: Gradient(colors: [Color.zetaBackgroundGradientStart, Color.zetaBackgroundGradientEnd]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                StarfieldView(geometry: geometry, dragOffset: $parallaxDragOffset)
                ParallaxBackgroundElements(geometry: geometry, dragOffset: $parallaxDragOffset)
                
                // --- Main Content ---
                mainContentView(geometry: geometry)
            }
            .gesture(createDragGesture())
            .onAppear(perform: setupView)
        }
        .statusBar(hidden: true)
    }
    
    // MARK: - Main Content
    @ViewBuilder private func mainContentView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 20) {
            // --- Header & Back Button ---
            headerView
                .padding(.top, geometry.safeAreaInsets.top > 20 ? geometry.safeAreaInsets.top - 10 : 10)
            
            // --- Challenge Scenario Cards ---
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    ForEach(Array(ChallengeType.allCases.enumerated()), id: \.element) { index, type in
                        ChallengeCardView(
                            challengeType: type,
                            selectedChallenge: $selectedChallenge
                        )
                        .offset(y: showContent ? 0 : 50)
                        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3 + Double(index) * 0.07), value: showContent)
                    }
                }
                .padding(.top, 10)
            }

            // --- Continue Button ---
            continueButton
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom + 5 : 35)
        }
        .padding(.horizontal)
        .opacity(showContent ? 1 : 0)
        .animation(.easeInOut(duration: 0.5), value: showContent)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedChallenge)
    }

    // MARK: - Subviews
    private var headerView: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white.opacity(0.8))
                    .padding(10)
                    .background(.black.opacity(0.15))
                    .clipShape(Circle())
            }
            .offset(y: showContent ? 0 : -50)
            .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1), value: showContent)
            
            Spacer()
            
            // CORRECTED: Updated question text
            Text("What challenge does our hero overcome?")
                .font(.custom("Avenir-Heavy", size: 22))
                .foregroundStyle(Color.welcomeViewTextPrimary)
                .shadow(color: Color.welcomeViewTextPrimary.opacity(0.15), radius: 1, x: 0, y: 1)
                .multilineTextAlignment(.center)
                .offset(x: -25) // Adjust to center title
            
            Spacer()
        }
        .frame(height: 50)
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
    }
    
    private var continueButton: some View {
        Button(action: handleNext) {
            HStack(spacing: 10) {
                Text("Continue")
                    .font(.custom("Avenir-Heavy", size: 19))
                Image(systemName: "arrow.right")
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 18)
            .frame(width: 270, height: 56)
            .foregroundStyle(selectedChallenge == nil ? .white.opacity(0.6) : .white)
            .background(continueButtonBackground)
            .shadow(color: Color.welcomeViewButtonPurpleDark.opacity(0.35), radius: 9, x: 0, y: 4)
        }
        .scaleEffect(continueButtonScale)
        .disabled(selectedChallenge == nil)
        .offset(y: showContent ? 0 : 50)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: showContent)
    }

    @ViewBuilder private var continueButtonBackground: some View {
        let isDisabled = selectedChallenge == nil
        ZStack {
            Capsule().fill(LinearGradient(
                colors: [
                    isDisabled ? .gray.opacity(0.5) : Color.welcomeViewButtonPurpleDark,
                    isDisabled ? .gray.opacity(0.3) : Color.purple.opacity(0.8)
                ],
                startPoint: .leading, endPoint: .trailing
            ))
            Capsule().strokeBorder(LinearGradient(colors: [.white.opacity(0.55), .white.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1.2)
        }
    }
    
    // MARK: - Functions & Logic
    private func setupView() {
        if let savedChallenge = storyElements.challenge,
           let type = ChallengeType(rawValue: savedChallenge) {
            selectedChallenge = type
        }
        showContent = true
    }

    private func handleNext() {
        storyElements.challenge = selectedChallenge?.rawValue
        
        withAnimation(.spring(response:0.3, dampingFraction:0.55)) { continueButtonScale = 0.92 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            onNext()
            continueButtonScale = 1.0
        }
    }
    
    private func createDragGesture() -> some Gesture {
        DragGesture().onChanged { value in
            let maxOffset: CGFloat = 20
            parallaxDragOffset = CGSize(
                width: clamp(value.translation.width / 10, min: -maxOffset, max: maxOffset),
                height: clamp(value.translation.height / 10, min: -maxOffset, max: maxOffset)
            )
        }.onEnded { _ in
            withAnimation(.spring(response: 0.45, dampingFraction: 0.65)) { parallaxDragOffset = .zero }
        }
    }
    
    private func clamp(_ val: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        Swift.min(max, Swift.max(min, val))
    }
}


// MARK: - ChallengeType Model
// CORRECTED: Renamed enum and updated all text properties to match the new "challenge" tone.
enum ChallengeType: String, CaseIterable, Identifiable {
    case findingLost = "finding_something_lost"
    case facingShadow = "facing_a_scary_shadow"
    case makingFriend = "making_a_new_friend"
    case learningLesson = "learning_an_important_lesson"
    case gettingReadyForBed = "getting_ready_for_bedtime"

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .findingLost: "Finding Something Lost"
        case .facingShadow: "Facing a Scary Shadow"
        case .makingFriend: "Making a New Friend"
        case .learningLesson: "Learning a Lesson"
        case .gettingReadyForBed: "Getting Ready for Bed"
        }
    }
    
    var description: String {
        switch self {
        case .findingLost: "A precious item has vanished and must be found."
        case .facingShadow: "Mustering the courage to see what lurks in the dark."
        case .makingFriend: "Overcoming shyness to say hello to someone new."
        case .learningLesson: "About being brave, kind, or trying new things."
        case .gettingReadyForBed: "The final, cozy adventure before drifting off to sleep."
        }
    }

    var sfSymbolName: String {
        switch self {
        case .findingLost: "sparkle.magnifyingglass"
        case .facingShadow: "moon.stars.fill"
        case .makingFriend: "person.2.wave.2.fill"
        case .learningLesson: "brain.head.profile"
        case .gettingReadyForBed: "bed.double.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .findingLost: .yellow
        case .facingShadow: .indigo
        case .makingFriend: .green
        case .learningLesson: .orange
        case .gettingReadyForBed: .teal
        }
    }
}


// MARK: - ChallengeCardView Subview

struct ChallengeCardView: View {
    let challengeType: ChallengeType
    @Binding var selectedChallenge: ChallengeType?
    
    private var isSelected: Bool { selectedChallenge == challengeType }

    var body: some View {
        Button(action: {
            selectedChallenge = challengeType
        }) {
            HStack(spacing: 20) {
                // Illustration
                ZStack {
                    Circle()
                        .fill(challengeType.color.opacity(isSelected ? 0.9 : 0.4))
                        .frame(width: 60, height: 60)
                        .blur(radius: isSelected ? 3 : 0)
                    
                    Image(systemName: challengeType.sfSymbolName)
                        .font(.system(size: 28, weight: .bold))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            .white,
                            challengeType.color.opacity(isSelected ? 1.0 : 0.7)
                        )
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(challengeType.title)
                        .font(.custom("Avenir-Heavy", size: 18))
                        .foregroundStyle(.white)
                    
                    Text(challengeType.description)
                        .font(.custom("Avenir-Medium", size: 14))
                        .foregroundStyle(.white.opacity(0.8))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 95)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.black.opacity(isSelected ? 0.3 : 0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(isSelected ? challengeType.color : Color.white.opacity(0.2), lineWidth: isSelected ? 2.5 : 1)
                    )
            )
            .scaleEffect(isSelected ? 1.03 : 1.0)
            .shadow(color: isSelected ? challengeType.color.opacity(0.4) : .clear, radius: 10, y: 5)
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Preview Provider

struct ProblemQuestionView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var storyElements = StoryElements()
        
        var body: some View {
            ProblemQuestionView(
                storyElements: $storyElements,
                onNext: { print("Preview: Next tapped. Challenge: \(storyElements.challenge ?? "nil")") },
                onBack: { print("Preview: Back tapped.") }
            )
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
            .preferredColorScheme(.dark)
    }
}
