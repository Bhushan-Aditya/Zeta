import SwiftUI

// MARK: - EndingQuestionView

struct EndingQuestionView: View {
    // --- State & Bindings ---
    @Binding var storyElements: StoryElements
    let onNext: () -> Void
    let onBack: () -> Void

    // Internal state for this view
    @State private var selectedEnding: EndingType?
    @State private var parallaxDragOffset: CGSize = .zero
    
    // Animation state
    @State private var showContent = false
    @State private var continueButtonScale: CGFloat = 1.0

    // Grid layout for the ending buttons
    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 16), count: 2)

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
            
            // --- Ending Selection Grid ---
            endingGrid
                .padding(.top, 10)

            Spacer()
            
            // --- Continue Button ---
            continueButton
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom + 5 : 35)
        }
        .padding(.horizontal)
        .opacity(showContent ? 1 : 0)
        .animation(.easeInOut(duration: 0.5), value: showContent)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedEnding)
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
            
            Text("How should the story end?")
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
    
    private var endingGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(EndingType.allCases.enumerated()), id: \.element) { index, type in
                EndingTypeButton(
                    endingType: type,
                    selectedEnding: $selectedEnding
                )
                .offset(y: showContent ? 0 : 50)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3 + Double(index) * 0.07), value: showContent)
            }
        }
    }
    
    private var continueButton: some View {
        Button(action: handleNext) {
            HStack(spacing: 10) {
                // The final button can have a more conclusive label
                Text("Finish Story")
                    .font(.custom("Avenir-Heavy", size: 19))
                Image(systemName: "wand.and.stars")
                    .fontWeight(.bold)
            }
            .padding(.horizontal, 18)
            .frame(width: 270, height: 56)
            .foregroundStyle(selectedEnding == nil ? .white.opacity(0.6) : .white)
            .background(continueButtonBackground)
            .shadow(color: Color.welcomeViewButtonPurpleDark.opacity(0.35), radius: 9, x: 0, y: 4)
        }
        .scaleEffect(continueButtonScale)
        .disabled(selectedEnding == nil)
        .offset(y: showContent ? 0 : 50)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: showContent)
    }

    @ViewBuilder private var continueButtonBackground: some View {
        let isDisabled = selectedEnding == nil
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
        if let savedEnding = storyElements.endingFeeling,
           let type = EndingType(rawValue: savedEnding) {
            selectedEnding = type
        }
        showContent = true
    }

    private func handleNext() {
        storyElements.endingFeeling = selectedEnding?.rawValue
        
        withAnimation(.spring(response:0.3, dampingFraction:0.55)) { continueButtonScale = 0.92 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            onNext() // This will now likely navigate to the .storyPreview step
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


// MARK: - EndingType Model

enum EndingType: String, CaseIterable, Identifiable {
    case peacefulSleep = "peaceful_sleep"
    case happyDreams = "happy_dreams"
    case feelingBrave = "feeling_brave"
    case learningNew = "learning_new"
    case familyCuddles = "family_cuddles"

    var id: String { self.rawValue }

    var label: String {
        switch self {
        case .peacefulSleep: "Peaceful Sleep"
        case .happyDreams: "Happy Dreams"
        case .feelingBrave: "Feeling Brave"
        case .learningNew: "Learning Something"
        case .familyCuddles: "Family Cuddles"
        }
    }

    var sfSymbolName: String {
        switch self {
        case .peacefulSleep: "sleep.circle.fill"
        case .happyDreams: "wand.and.stars.inverse"
        case .feelingBrave: "shield.fill"
        case .learningNew: "lightbulb.fill"
        case .familyCuddles: "heart.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .peacefulSleep: .blue
        case .happyDreams: .purple
        case .feelingBrave: .yellow
        case .learningNew: .orange
        case .familyCuddles: .pink
        }
    }
}


// MARK: - EndingTypeButton Subview

struct EndingTypeButton: View {
    let endingType: EndingType
    @Binding var selectedEnding: EndingType?
    
    private var isSelected: Bool { selectedEnding == endingType }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: endingType.sfSymbolName)
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(endingType.color, .white.opacity(0.8))
                .frame(height: 45)
                // This gentle "breathing" animation activates on selection.
                .symbolEffect(.variableColor.iterative.reversing, options: .repeating.speed(1), isActive: isSelected)

            Text(endingType.label)
                .font(.custom("Avenir-Medium", size: 16))
                .foregroundStyle(isSelected ? .white : .white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.black.opacity(isSelected ? 0.3 : 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(isSelected ? endingType.color : Color.white.opacity(0.2), lineWidth: isSelected ? 2.5 : 1)
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .shadow(color: isSelected ? endingType.color.opacity(0.4) : .clear, radius: 10, y: 5)
        .onTapGesture {
            selectedEnding = endingType
        }
    }
}


// MARK: - Preview Provider

struct EndingQuestionView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var storyElements = StoryElements()
        
        var body: some View {
            EndingQuestionView(
                storyElements: $storyElements,
                onNext: { print("Preview: Next tapped. Ending: \(storyElements.endingFeeling ?? "nil")") },
                onBack: { print("Preview: Back tapped.") }
            )
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
            .preferredColorScheme(.dark)
    }
}
