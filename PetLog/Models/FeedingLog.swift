import Foundation
import SwiftData

enum FoodType: String, Codable, CaseIterable, Identifiable {
    case dry, wet, raw, treat, supplement
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .dry: return "bag.fill"
        case .wet: return "takeoutbag.and.cup.and.straw.fill"
        case .raw: return "leaf.fill"
        case .treat: return "star.fill"
        case .supplement: return "pill.fill"
        }
    }
}

@Model
final class FeedingLog {
    var id: UUID
    var date: Date
    var time: Date
    var foodBrand: String
    var foodType: FoodType
    var amount: Double?
    var unit: String
    var calories: Int?
    var notes: String
    var createdAt: Date

    var pet: Pet?

    init(
        date: Date = Date(),
        time: Date = Date(),
        foodBrand: String = "",
        foodType: FoodType = .dry,
        amount: Double? = nil,
        unit: String = "cups",
        calories: Int? = nil,
        notes: String = "",
        pet: Pet? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.time = time
        self.foodBrand = foodBrand
        self.foodType = foodType
        self.amount = amount
        self.unit = unit
        self.calories = calories
        self.notes = notes
        self.createdAt = Date()
        self.pet = pet
    }

    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}
