import Foundation

struct PromptGenerator {

    func generatePrompt(from elements: StoryElements) -> String {
        // --- Convert raw values back to human-readable labels ---
        // This makes the prompt clearer for the LLM.
        
        // Handle character, including optional name
        var characterDescription = CharacterType(rawValue: elements.mainCharacter ?? "")?.label ?? "A brave hero"
        if let characterName = elements.characterName, !characterName.isEmpty {
            characterDescription = "\(characterName) the \(CharacterType(rawValue: elements.mainCharacter ?? "")?.label.lowercased() ?? "hero")"
        }
        
        let settingLabel = LocationType(rawValue: elements.setting ?? "")?.label ?? "A magical land"
        let helperLabel = HelperType(rawValue: elements.helper ?? "")?.label ?? "A kind friend"
        let challengeLabel = ChallengeType(rawValue: elements.challenge ?? "")?.title ?? "An interesting challenge"
        let magicLabel = MagicalElementType(rawValue: elements.magicalElement ?? "")?.label ?? "A wondrous magic"
        let endingLabel = EndingType(rawValue: elements.endingFeeling ?? "")?.label ?? "A happy ending"
        
        // --- Assemble the final prompt using the template ---
        let promptTemplate = """
        Generate a soothing 150-word bedtime story for a toddler based on these elements:

        Main Character: \(characterDescription)
        Setting: \(settingLabel)
        Helper/Friend: \(helperLabel)
        Challenge: \(challengeLabel)
        Magical Element: \(magicLabel)
        Desired Ending Feeling: \(endingLabel)

        Requirements:
        - Keep the story exactly 150 words.
        - Use simple language appropriate for toddlers (ages 2-4).
        - Start with "Once upon a time" or a similar gentle opening.
        - Include a small problem that gets resolved with help.
        - Incorporate the magical element in a wonder-inspiring way.
        - End the story with a calm, peaceful resolution that evokes the desired ending feeling.
        - Include a simple, clear moral lesson that toddlers can understand.
        - Avoid scary elements, loud noises, or anything that might disrupt bedtime.
        - Use gentle, soothing language throughout.
        - Include 2-3 descriptive sentences about the setting to help visualize the world.
        - Make sure the story has a clear beginning, middle, and end.
        - End with the moral of the story, followed by a line that gently encourages sleep or sweet dreams.

        Return only the story text without any additional commentary.
        """
        
        return promptTemplate
    }
}
