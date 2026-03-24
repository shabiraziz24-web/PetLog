import Foundation
import SwiftData

enum WeightUnit: String, Codable, CaseIterable, Identifiable {
    case lb, kg
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .lb: return "lbs"
        case .kg: return "kg"
        }
    }
}

@Model
final class WeightEntry {
    var id: UUID
    var date: Date
    var weight: Double
    var unit: WeightUnit
    var notes: String
    var createdAt: Date

    var pet: Pet?

    init(
        date: Date = Date(),
        weight: Double = 0,
        unit: WeightUnit = .lb,
        notes: String = "",
        pet: Pet? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.weight = weight
        self.unit = unit
        self.notes = notes
        self.createdAt = Date()
        self.pet = pet
    }

    var weightFormatted: String {
        String(format: "%.1f %@", weight, unit.displayName)
    }
}
