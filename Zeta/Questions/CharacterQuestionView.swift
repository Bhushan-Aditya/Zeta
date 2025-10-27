import SwiftUI

// MARK: - CharacterQuestionView

struct CharacterQuestionView: View {
    // --- State & Bindings ---
    @Binding var storyElements: StoryElements
    let onNext: () -> Void
    let onBack: () -> Void

    // Internal state for this view
    @State private var selectedCharacter: CharacterType?
    @State private var characterName: String = ""
    @State private var parallaxDragOffset: CGSize = .zero
    
    // Animation state
    @State private var showContent = false
    @State private var continueButtonScale: CGFloat = 1.0

    // Grid layout for the character buttons
    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 16), count: 2)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // --- Reusing Background Elements for Consistency ---
                // Ensure your Color extensions and background views are accessible.
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
        VStack(spacing: 0) {
            // --- Header & Back Button ---
            headerView
                .padding(.top, geometry.safeAreaInsets.top > 20 ? geometry.safeAreaInsets.top - 10 : 10)
                .padding(.bottom, 20)

            // --- Character Selection Grid ---
            characterGrid
                .padding(.horizontal)

            // --- Optional Name Input Field ---
            if selectedCharacter != nil {
                nameInputField
                    .padding(.top, 25)
                    .transition(.opacity.combined(with: .offset(y: 20)))
            }

            Spacer()
            
            // --- Continue Button ---
            continueButton
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom + 5 : 35)
        }
        .padding(.horizontal)
        .opacity(showContent ? 1 : 0)
        .animation(.easeInOut(duration: 0.5), value: showContent)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedCharacter)
    }

    // MARK: - Subviews
    private var headerView: some View {
        HStack {
            // Back Button
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
            
            Text("Who is the story about?")
                .font(.custom("Avenir-Heavy", size: 24))
                .foregroundStyle(Color.welcomeViewTextPrimary)
                .shadow(color: Color.welcomeViewTextPrimary.opacity(0.15), radius: 1, x: 0, y: 1)
                .multilineTextAlignment(.center)
                .offset(x: -25) // Adjust to center title properly with back button present
            
            Spacer()
        }
        .frame(height: 50)
        .opacity(showContent ? 1 : 0)
        .animation(.easeOut(duration: 0.6).delay(0.2), value: showContent)
    }
    
    private var characterGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(CharacterType.allCases.enumerated()), id: \.element) { index, type in
                CharacterTypeButton(
                    characterType: type,
                    selectedCharacter: $selectedCharacter
                )
                .offset(y: showContent ? 0 : 50)
                .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3 + Double(index) * 0.07), value: showContent)
            }
        }
    }
    
    @ViewBuilder private var nameInputField: some View {
        HStack {
            Image(systemName: "pencil.line")
                .foregroundColor(Color.welcomeViewTextPrimary.opacity(0.6))
            
            TextField("Character's name (optional)", text: $characterName)
                .font(.custom("Avenir-Medium", size: 17))
                .foregroundStyle(Color.welcomeViewTextPrimary)
                .tint(Color.zetaSoftOrange) // Cursor color
        }
        .padding(.horizontal, 20)
        .frame(height: 55)
        .background(
            Capsule().fill(.black.opacity(0.15))
                .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
        )
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
            .foregroundStyle(selectedCharacter == nil ? .white.opacity(0.6) : .white)
            .background(continueButtonBackground) // Reusing button style
            .shadow(color: Color.welcomeViewButtonPurpleDark.opacity(0.35), radius: 9, x: 0, y: 4)
        }
        .scaleEffect(continueButtonScale)
        .disabled(selectedCharacter == nil)
        .offset(y: showContent ? 0 : 50)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.6), value: showContent)
    }

    // Reusing the beautiful button style from WelcomeView
    @ViewBuilder private var continueButtonBackground: some View {
        let isDisabled = selectedCharacter == nil
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
        // If navigating back, restore the previous selection
        if let savedCharacter = storyElements.mainCharacter,
           let type = CharacterType(rawValue: savedCharacter) {
            selectedCharacter = type
        }
        if let savedName = storyElements.characterName {
            characterName = savedName
        }
        
        // Trigger entry animations
        showContent = true
    }

    private func handleNext() {
        // Save the data to the central model
        storyElements.mainCharacter = selectedCharacter?.rawValue
        // Store name only if it's not empty, otherwise store nil
        storyElements.characterName = characterName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : characterName

        // Animate button press and trigger coordinator's onNext
        withAnimation(.spring(response:0.3, dampingFraction:0.55)) { continueButtonScale = 0.92 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            onNext()
            continueButtonScale = 1.0 // Reset for when user navigates back
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


// MARK: - CharacterType Model
// This enum defines the options and their visual properties.
// It can be in this file or moved to Models.swift for organization.

enum CharacterType: String, CaseIterable, Identifiable {
    case child
    case animal
    case magicalCreature = "magical_creature"
    case superhero
    case toy

    var id: String { self.rawValue }

    var label: String {
        switch self {
            case .child: "A Child"
            case .animal: "An Animal"
            case .magicalCreature: "Magical Creature"
            case .superhero: "A Superhero"
            case .toy: "A Favorite Toy"
        }
    }

    var sfSymbolName: String {
        switch self {
            case .child: "figure.child"
            case .animal: "pawprint.fill"
            case .magicalCreature: "sparkles.and.sparkles.fill"
            case .superhero: "shield.lefthalf.filled"
            case .toy: "teddybear.fill"
        }
    }
}


// MARK: - CharacterTypeButton Subview

struct CharacterTypeButton: View {
    let characterType: CharacterType
    @Binding var selectedCharacter: CharacterType?
    
    private var isSelected: Bool { selectedCharacter == characterType }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: characterType.sfSymbolName)
                .font(.system(size: 40, weight: .bold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    isSelected ? Color.zetaSoftOrange : Color.white.opacity(0.9),
                    isSelected ? Color.white : Color.white.opacity(0.6)
                )
                .frame(height: 45)
            
            Text(characterType.label)
                .font(.custom("Avenir-Medium", size: 16))
                .foregroundStyle(isSelected ? Color.white : Color.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 130)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.black.opacity(isSelected ? 0.25 : 0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(isSelected ? Color.zetaSoftOrange : Color.white.opacity(0.2), lineWidth: isSelected ? 2.5 : 1)
                )
                .shadow(color: isSelected ? Color.zetaSoftOrange.opacity(0.35) : .clear, radius: 10, y: 5)
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .onTapGesture {
            selectedCharacter = characterType
        }
    }
}


// MARK: - Preview Provider

struct CharacterQuestionView_Previews: PreviewProvider {
    // A simple state holder for the preview
    struct PreviewWrapper: View {
        @State var storyElements = StoryElements()
        
        var body: some View {
            CharacterQuestionView(
                storyElements: $storyElements,
                onNext: { print("Preview: Next tapped. Elements: \(storyElements)") },
                onBack: { print("Preview: Back tapped.") }
            )
        }
    }
    
    static var previews: some View {
        // You MUST have these helper views and color extensions available for the preview to work.
        // Assuming they are in your project.
        PreviewWrapper()
            .preferredColorScheme(.dark)
    }
}
