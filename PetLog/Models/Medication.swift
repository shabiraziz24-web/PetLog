import Foundation
import SwiftData
import SwiftUI

enum MedicationFrequency: String, Codable, CaseIterable, Identifiable {
    case daily, weekly, monthly, asNeeded
    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .asNeeded: return "As Needed"
        }
    }
}

@Model
final class Medication {
    var id: UUID
    var name: String
    var dosage: String
    var frequency: MedicationFrequency
    var startDate: Date
    var endDate: Date?
    var timeOfDay: Date?
    var instructions: String
    var refillDate: Date?
    var prescribedBy: String
    var cost: Double?
    var isActive: Bool
    var createdAt: Date

    var pet: Pet?

    init(
        name: String = "",
        dosage: String = "",
        frequency: MedicationFrequency = .daily,
        startDate: Date = Date(),
        endDate: Date? = nil,
        timeOfDay: Date? = nil,
        instructions: String = "",
        refillDate: Date? = nil,
        prescribedBy: String = "",
        cost: Double? = nil,
        isActive: Bool = true,
        pet: Pet? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.frequency = frequency
        self.startDate = startDate
        self.endDate = endDate
        self.timeOfDay = timeOfDay
        self.instructions = instructions
        self.refillDate = refillDate
        self.prescribedBy = prescribedBy
        self.cost = cost
        self.isActive = isActive
        self.createdAt = Date()
        self.pet = pet
    }

    var needsRefill: Bool {
        guard let refillDate else { return false }
        let oneWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date())!
        return refillDate < oneWeek
    }

    var timeOfDayFormatted: String {
        guard let timeOfDay else { return "Any time" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timeOfDay)
    }

    var statusColor: Color {
        if !isActive { return .gray }
        if needsRefill { return .orange }
        return .green
    }
}
