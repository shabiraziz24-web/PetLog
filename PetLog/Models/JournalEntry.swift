import Foundation
import SwiftData
import SwiftUI

enum PetMood: String, Codable, CaseIterable, Identifiable {
    case happy, neutral, sick, energetic, lazy
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .neutral: return "😐"
        case .sick: return "🤒"
        case .energetic: return "⚡"
        case .lazy: return "😴"
        }
    }
    var color: Color {
        switch self {
        case .happy: return .yellow
        case .neutral: return .gray
        case .sick: return .red
        case .energetic: return .orange
        case .lazy: return .blue
        }
    }
}

enum MilestoneType: String, Codable, CaseIterable, Identifiable {
    case firstWalk, birthday, adoption, trick, other, none
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .firstWalk: return "First Walk"
        case .birthday: return "Birthday"
        case .adoption: return "Adoption Day"
        case .trick: return "New Trick"
        case .other: return "Other"
        case .none: return "None"
        }
    }
    var icon: String {
        switch self {
        case .firstWalk: return "figure.walk"
        case .birthday: return "birthday.cake.fill"
        case .adoption: return "heart.fill"
        case .trick: return "star.fill"
        case .other: return "flag.fill"
        case .none: return ""
        }
    }
}

@Model
final class JournalEntry {
    var id: UUID
    var date: Date
    var title: String
    var text: String
    @Attribute(.externalStorage) var photosData: [Data]
    var mood: PetMood
    var milestoneType: MilestoneType
    var createdAt: Date

    var pet: Pet?

    init(
        date: Date = Date(),
        title: String = "",
        text: String = "",
        photosData: [Data] = [],
        mood: PetMood = .happy,
        milestoneType: MilestoneType = .none,
        pet: Pet? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.title = title
        self.text = text
        self.photosData = photosData
        self.mood = mood
        self.milestoneType = milestoneType
        self.createdAt = Date()
        self.pet = pet
    }

    var isMilestone: Bool { milestoneType != .none }
}
