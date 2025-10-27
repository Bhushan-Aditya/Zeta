import SwiftUI

// Enum to manage the flow of question views. It acts as our navigation map.
enum StoryCreationStep: Hashable {
    case character
    case location
    case helper
    case problem
    case magic
    case ending
    case storyPreview
    case storyDisplay
}

struct StoryCreationCoordinatorView: View {
    @Binding var isPresented: Bool // Binding to control the presentation of this whole flow

    // The single source of truth for all user choices
    @State private var storyElements = StoryElements()
    // The state that controls which view is shown
    @State private var currentStep: StoryCreationStep = .character
    
    // State for the final story generation
    @State private var generatedStory: String = ""
    @State private var isLoadingStory: Bool = false

    // An instance of our API service to talk to Gemini
    private let apiService = GeminiAPIService()

    var body: some View {
        // The ZStack and switch statement are the engine of our custom navigation.
        // Changing 'currentStep' swaps the view, and .transition handles the animation.
        ZStack {
            switch currentStep {
            
            // Step 1: Character
            case .character:
                CharacterQuestionView(
                    storyElements: $storyElements,
                    onNext: { navigate(to: .location) },
                    onBack: { isPresented = false } // First step, so back dismisses the flow
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            // Step 2: Location
            case .location:
                LocationQuestionView(
                    storyElements: $storyElements,
                    onNext: { navigate(to: .helper) },
                    onBack: { navigate(to: .character) }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            
            // Step 3: Helper
            case .helper:
                 HelperQuestionView(
                    storyElements: $storyElements,
                    onNext: { navigate(to: .problem) },
                    onBack: { navigate(to: .location) }
                 )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            
            // Step 4: Challenge
            case .problem:
                ProblemQuestionView(
                    storyElements: $storyElements,
                    onNext: { navigate(to: .magic) },
                    onBack: { navigate(to: .helper) }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            // Step 5: Magic
            case .magic:
                MagicalElementQuestionView(
                    storyElements: $storyElements,
                    onNext: { navigate(to: .ending) },
                    onBack: { navigate(to: .problem) }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            // Step 6: Ending
            case .ending:
                EndingQuestionView(
                    storyElements: $storyElements,
                    onNext: { navigate(to: .storyPreview) },
                    onBack: { navigate(to: .magic) }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))

            // Step 7: Story Preview (Summary Screen)
            case .storyPreview:
                // Using the real StoryPreviewView now
                StoryPreviewView(
                    storyElements: storyElements,
                    onGenerate: { generateAndDisplayStory() },
                    onBack: { navigate(to: .ending) }
                )
                .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            
            // Step 8: Final Story Display
            case .storyDisplay:
                // Using the real StoryDisplayView now
                StoryDisplayView(
                    storyText: generatedStory,
                    isLoading: isLoadingStory,
                    onDone: { isPresented = false }
                )
                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
            }
        }
        .navigationBarHidden(true)
        .ignoresSafeArea(.keyboard)
    }
    
    // MARK: - Navigation and Logic
    
    /// A clean helper function to handle navigation between steps.
    private func navigate(to step: StoryCreationStep) {
        withAnimation(.easeInOut) {
            currentStep = step
        }
    }
    
    /// The main function that generates the prompt and handles the API call.
    private func generateAndDisplayStory() {
        // First, check if the API service was initialized correctly (i.e., key was found)
        guard let service = apiService else {
            self.generatedStory = "API Key not found. Please create a Configuration.plist file and add your GeminiAPIKey."
            self.isLoadingStory = false
            navigate(to: .storyDisplay)
            return
        }
        
        // 1. Move to the display screen immediately to show the loading indicator.
        isLoadingStory = true
        navigate(to: .storyDisplay)
        
        // 2. Generate the prompt using our utility.
        let generator = PromptGenerator()
        let prompt = generator.generatePrompt(from: storyElements)
        
        // 3. Print the prompt for your debugging. You can see it in the Xcode console.
        print("--- Sending Prompt to Gemini ---")
        print(prompt)
        print("------------------------------")

        // 4. This Task runs the network call in the background using our new service.
        Task {
            let result = await service.generateStory(prompt: prompt)
            
            // 5. This brings the result back to the main thread to safely update the UI.
            await MainActor.run {
                switch result {
                case .success(let storyText):
                    self.generatedStory = storyText
                case .failure(let error):
                    // Provide a user-friendly error message
                    self.generatedStory = "Oh no! The story magic fizzled. Please try again.\n\n(Error: \(error.localizedDescription))"
                }
                // Hide the spinner and show the result (either the story or the error).
                self.isLoadingStory = false
            }
        }
    }
}

// --- Preview for StoryCreationCoordinatorView ---
struct StoryCreationCoordinatorView_Previews: PreviewProvider {
    @State static var mockIsPresented = true
    static var previews: some View {
        StoryCreationCoordinatorView(isPresented: $mockIsPresented)
    }
}
