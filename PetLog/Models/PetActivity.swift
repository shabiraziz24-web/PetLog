import Foundation
import SwiftData
import SwiftUI

enum ActivityType: String, Codable, CaseIterable, Identifiable {
    case walk, run, play, training, swim, other
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .walk: return "figure.walk"
        case .run: return "figure.run"
        case .play: return "tennisball.fill"
        case .training: return "brain.head.profile"
        case .swim: return "figure.pool.swim"
        case .other: return "star.fill"
        }
    }
    var color: Color {
        switch self {
        case .walk: return .blue
        case .run: return .orange
        case .play: return .green
        case .training: return .purple
        case .swim: return .cyan
        case .other: return .gray
        }
    }
}

@Model
final class PetActivity {
    var id: UUID
    var date: Date
    var type: ActivityType
    var duration: TimeInterval
    var distance: Double?
    var route: String?
    var calories: Int?
    var notes: String
    var createdAt: Date

    var pet: Pet?

    init(
        date: Date = Date(),
        type: ActivityType = .walk,
        duration: TimeInterval = 0,
        distance: Double? = nil,
        route: String? = nil,
        calories: Int? = nil,
        notes: String = "",
        pet: Pet? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.duration = duration
        self.distance = distance
        self.route = route
        self.calories = calories
        self.notes = notes
        self.createdAt = Date()
        self.pet = pet
    }

    var durationFormatted: String {
        let minutes = Int(duration) / 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return "\(hours)h \(remainingMinutes)m"
        }
        return "\(remainingMinutes)m"
    }

    var distanceFormatted: String {
        guard let distance else { return "--" }
        return String(format: "%.1f mi", distance)
    }
}
