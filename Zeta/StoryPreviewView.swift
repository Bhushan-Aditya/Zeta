import SwiftUI

struct StoryPreviewView: View {
    let storyElements: StoryElements
    let onGenerate: () -> Void
    let onBack: () -> Void
    
    // Animation State
    @State private var showContent = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Consistent Background
                LinearGradient(gradient: Gradient(colors: [Color.zetaBackgroundGradientStart, Color.zetaBackgroundGradientEnd]), startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                StarfieldView(geometry: geometry, dragOffset: .constant(.zero))
                
                VStack(spacing: 20) {
                    headerView
                        .padding(.top, geometry.safeAreaInsets.top > 20 ? geometry.safeAreaInsets.top - 10 : 10)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 16) {
                            summaryCard(title: "Your Hero's Journey", elements: storyElements)
                        }
                        .padding()
                    }
                    
                    generateButton
                        .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? geometry.safeAreaInsets.bottom : 20)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                .animation(.easeInOut(duration: 0.6), value: showContent)
                .onAppear { showContent = true }
            }
        }
    }
    
    // MARK: - Subviews
    private var headerView: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.bold)).foregroundColor(.white.opacity(0.8))
                    .padding(10).background(.black.opacity(0.15)).clipShape(Circle())
            }
            Spacer()
            Text("Ready for Magic?").font(.custom("Avenir-Heavy", size: 24)).foregroundStyle(Color.welcomeViewTextPrimary)
            Spacer()
            // Placeholder to balance the back button
            Circle().fill(Color.clear).frame(width: 44, height: 44)
        }.padding(.horizontal)
    }
    
    @ViewBuilder
    private func summaryCard(title: String, elements: StoryElements) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title)
                .font(.custom("Avenir-Heavy", size: 22))
                .foregroundStyle(.white)
            
            summaryRow(icon: "figure.child", label: "Hero", value: getCharacterDescription(from: elements))
            summaryRow(icon: "mappin.and.ellipse", label: "Setting", value: LocationType(rawValue: elements.setting ?? "")?.label ?? "N/A")
            summaryRow(icon: "person.2.fill", label: "Friend", value: HelperType(rawValue: elements.helper ?? "")?.label ?? "N/A")
            summaryRow(icon: "target", label: "Challenge", value: ChallengeType(rawValue: elements.challenge ?? "")?.title ?? "N/A")
            summaryRow(icon: "sparkles", label: "Magic", value: MagicalElementType(rawValue: elements.magicalElement ?? "")?.label ?? "N/A")
            summaryRow(icon: "moon.zzz.fill", label: "Ending", value: EndingType(rawValue: elements.endingFeeling ?? "")?.label ?? "N/A")
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.black.opacity(0.2))
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.white.opacity(0.2), lineWidth: 1))
        )
    }
    
    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(Color.zetaSoftOrange)
                .frame(width: 25, alignment: .center)
            
            Text(label)
                .font(.custom("Avenir-Heavy", size: 16))
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 80, alignment: .leading)
            
            Text(value)
                .font(.custom("Avenir-Medium", size: 16))
                .foregroundStyle(.white)
            
            Spacer()
        }
    }
    
    private var generateButton: some View {
        Button(action: onGenerate) {
            HStack(spacing: 12) {
                Image(systemName: "wand.and.stars")
                Text("Create My Story!")
                    .font(.custom("Avenir-Heavy", size: 19))
            }
            .padding(.horizontal, 18)
            .frame(width: 300, height: 56)
            .foregroundStyle(.white)
            .background(
                Capsule().fill(LinearGradient(colors: [.green, .cyan.opacity(0.7)], startPoint: .leading, endPoint: .trailing))
            )
            .shadow(color: .cyan.opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }
    
    // Helper to format the character description for the summary
    private func getCharacterDescription(from elements: StoryElements) -> String {
        guard let rawType = elements.mainCharacter, let type = CharacterType(rawValue: rawType) else {
            return elements.characterName ?? "A Hero"
        }
        
        if let name = elements.characterName, !name.isEmpty {
            return "\(name) the \(type.label.lowercased())"
        } else {
            return type.label
        }
    }
}
