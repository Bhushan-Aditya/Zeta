import SwiftUI

// MARK: - LocationQuestionView

struct LocationQuestionView: View {
    // --- State & Bindings ---
    @Binding var storyElements: StoryElements
    let onNext: () -> Void
    let onBack: () -> Void

    // Internal state for this view
    @State private var selectedLocation: LocationType?
    @State private var parallaxDragOffset: CGSize = .zero
    
    // Animation state
    @State private var showContent = false
    @State private var continueButtonScale: CGFloat = 1.0

    // Grid layout for the location buttons
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
            
            // --- Location Selection Grid ---
            locationGrid
                .padding(.top, 10)

            Spacer()
            
            // --- Continue Button ---
            continueButton
                .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom + 5 : 35)
        }
        .padding(.horizontal)
        .opacity(showContent ? 1 : 0)
        .animation(.easeInOut(duration: 0.5), value: showContent)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedLocation)
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
            
            Text("Where does the story take place?")
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
    
    private var locationGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Array(LocationType.allCases.enumerated()), id: \.element) { index, type in
                LocationTypeButton(
                    locationType: type,
                    selectedLocation: $selectedLocation
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
            .foregroundStyle(selectedLocation == nil ? .white.opacity(0.6) : .white)
            .background(continueButtonBackground)
            .shadow(color: Color.welcomeViewButtonPurpleDark.opacity(0.35), radius: 9, x: 0, y: 4)
        }
        .scaleEffect(continueButtonScale)
        .disabled(selectedLocation == nil)
        .offset(y: showContent ? 0 : 50)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.5), value: showContent)
    }

    @ViewBuilder private var continueButtonBackground: some View {
        let isDisabled = selectedLocation == nil
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
        if let savedSetting = storyElements.setting,
           let type = LocationType(rawValue: savedSetting) {
            selectedLocation = type
        }
        showContent = true
    }

    private func handleNext() {
        storyElements.setting = selectedLocation?.rawValue
        
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


// MARK: - LocationType Model
// This enum defines the setting options and their visual properties.
// It can be in this file or moved to Models.swift for organization.

enum LocationType: String, CaseIterable, Identifiable {
    case forest
    case castle
    case space
    case sea = "under_the_sea"
    case bedroom
    case cave

    var id: String { self.rawValue }

    var label: String {
        switch self {
        case .forest: "Enchanted Forest"
        case .castle: "Magical Castle"
        case .space: "Outer Space"
        case .sea: "Under the Sea"
        case .bedroom: "Cozy Bedroom"
        case .cave: "Crystal Cave"
        }
    }

    var sfSymbolName: String {
        switch self {
        case .forest: "tree.fill"
        case .castle: "building.columns.fill" // No castle symbol, this is a good alternative
        case .space: "moon.stars.fill"
        case .sea: "fish.fill"
        case .bedroom: "bed.double.fill"
        case .cave: "diamond.fill" // Represents a crystal cave well
        }
    }
}


// MARK: - LocationTypeButton Subview

struct LocationTypeButton: View {
    let locationType: LocationType
    @Binding var selectedLocation: LocationType?
    
    private var isSelected: Bool { selectedLocation == locationType }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: locationType.sfSymbolName)
                .font(.system(size: 40, weight: .bold))
                .symbolRenderingMode(.palette)
                .foregroundStyle(
                    isSelected ? Color.zetaSoftOrange : Color.white.opacity(0.9),
                    isSelected ? Color.white : Color.white.opacity(0.6)
                )
                .frame(height: 45)
            
            Text(locationType.label)
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
            selectedLocation = locationType
        }
    }
}


// MARK: - Preview Provider

struct LocationQuestionView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var storyElements = StoryElements()
        
        var body: some View {
            LocationQuestionView(
                storyElements: $storyElements,
                onNext: { print("Preview: Next tapped. Setting: \(storyElements.setting ?? "nil")") },
                onBack: { print("Preview: Back tapped.") }
            )
        }
    }
    
    static var previews: some View {
        // Ensure helper views and color extensions are available for the preview.
        PreviewWrapper()
            .preferredColorScheme(.dark)
    }
}
