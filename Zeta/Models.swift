// Models.swift
import Foundation // Or SwiftUI if you ever add @Published properties, not needed for this basic struct

struct StoryElements {
    var mainCharacter: String? // Stores CharacterType.rawValue
    var characterName: String?
    var setting: String?
    var helper: String?
    var challenge: String?
    var magicalElement: String?
    var endingFeeling: String?
}
