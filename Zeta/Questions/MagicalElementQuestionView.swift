import SwiftUI

// MARK: - MagicalElementQuestionView

struct MagicalElementQuestionView: View {
    // --- State & Bindings ---
    @Binding var storyElements: StoryElements
    let onNext: () -> Void
    let onBack: () -> Void

    // Internal state for this view
    @State private var selectedMagic: MagicalElementType?
    @State private var parallaxDragOffset: CGSize = .zero
    
    // Animation state
    @State private var showContent = false
    @State private var continueButtonScale: CGFloat = 1.0

    // Grid layout for the magic buttons
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
            
            // --- Magic Selection Grid ---
            magicGrid
                .padding(.top, 10)

            Spacer()
            
            // --- Continue Button ---
            continueButton
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom + 5 : 35)
        }
        .padding(.horizontal)
        .opacity(showContent ? 1 : 0)
        .animation(.easeInOut(duration: 0.5), value: showContent)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedMagic)
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
            
            Text("What magic happens?")
                .font(.custom("Avenir-Heavy", size: 24))
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
    
    private var magicGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(MagicalElementType.allCases.enumerated()), id: \.element) { index, type in
                MagicalElementButton(
                    magicType: type,
                    selectedMagic: $selectedMagic
                )
                .offset(y: showContent ? 0 : 50)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3 + Double(index) * 0.07), value: showContent)
            }
        }
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
            .foregroundStyle(selectedMagic == nil ? .white.opacity(0.6) : .white)
            .background(continueButtonBackground)
            .shadow(color: Color.welcomeViewButtonPurpleDark.opacity(0.35), radius: 9, x: 0, y: 4)
        }
        .scaleEffect(continueButtonScale)
        .disabled(selectedMagic == nil)
        .offset(y: showContent ? 0 : 50)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: showContent)
    }

    @ViewBuilder private var continueButtonBackground: some View {
        let isDisabled = selectedMagic == nil
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
        if let savedMagic = storyElements.magicalElement,
           let type = MagicalElementType(rawValue: savedMagic) {
            selectedMagic = type
        }
        showContent = true
    }

    private func handleNext() {
        storyElements.magicalElement = selectedMagic?.rawValue
        
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


// MARK: - MagicalElementType Model

enum MagicalElementType: String, CaseIterable, Identifiable {
    case flying
    case talkingToAnimals = "talking_to_animals"
    case sizeChange = "size_change"
    case timeTravel = "time_travel"
    case objectsComeAlive = "objects_come_alive"

    var id: String { self.rawValue }

    var label: String {
        switch self {
        case .flying: "Flying"
        case .talkingToAnimals: "Talking to Animals"
        case .sizeChange: "Growing Tiny/Giant"
        case .timeTravel: "Time Travel"
        case .objectsComeAlive: "Objects Come Alive"
        }
    }

    var sfSymbolName: String {
        switch self {
        case .flying: "wind"
        case .talkingToAnimals: "bubble.left.and.bubble.right.fill"
        case .sizeChange: "arrow.up.left.and.arrow.down.right"
        case .timeTravel: "clock.arrow.2.circlepath"
        case .objectsComeAlive: "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .flying: .cyan
        case .talkingToAnimals: .green
        case .sizeChange: .purple
        case .timeTravel: .orange
        case .objectsComeAlive: .pink
        }
    }
}


// MARK: - MagicalElementButton Subview

struct MagicalElementButton: View {
    let magicType: MagicalElementType
    @Binding var selectedMagic: MagicalElementType?
    
    private var isSelected: Bool { selectedMagic == magicType }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: magicType.sfSymbolName)
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.white)
                .frame(height: 45)
                // This adds the subtle animation when the button is selected
                .symbolEffect(.pulse, options: .repeating.speed(0.5), isActive: isSelected)

            Text(magicType.label)
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
                        .stroke(isSelected ? magicType.color : Color.white.opacity(0.2), lineWidth: isSelected ? 2.5 : 1)
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .shadow(color: isSelected ? magicType.color.opacity(0.4) : .clear, radius: 10, y: 5)
        .onTapGesture {
            selectedMagic = magicType
        }
    }
}


// MARK: - Preview Provider

struct MagicalElementQuestionView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var storyElements = StoryElements()
        
        var body: some View {
            MagicalElementQuestionView(
                storyElements: $storyElements,
                onNext: { print("Preview: Next tapped. Magic: \(storyElements.magicalElement ?? "nil")") },
                onBack: { print("Preview: Back tapped.") }
            )
        }
    }
    
    static var previews: some View {
        PreviewWrapper()
            .preferredColorScheme(.dark)
    }
}
