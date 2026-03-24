import Foundation
import SwiftData
import SwiftUI

@Model
final class Vaccination {
    var id: UUID
    var name: String
    var dateAdministered: Date
    var nextDueDate: Date?
    var vetName: String
    var batchNumber: String
    var notes: String
    var createdAt: Date

    var pet: Pet?

    init(
        name: String = "",
        dateAdministered: Date = Date(),
        nextDueDate: Date? = nil,
        vetName: String = "",
        batchNumber: String = "",
        notes: String = "",
        pet: Pet? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.dateAdministered = dateAdministered
        self.nextDueDate = nextDueDate
        self.vetName = vetName
        self.batchNumber = batchNumber
        self.notes = notes
        self.createdAt = Date()
        self.pet = pet
    }

    var status: VaccinationStatus {
        guard let nextDueDate else { return .upToDate }
        let now = Date()
        if nextDueDate < now { return .overdue }
        let oneWeek = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: now)!
        if nextDueDate < oneWeek { return .dueSoon }
        return .upToDate
    }

    enum VaccinationStatus {
        case upToDate, dueSoon, overdue

        var label: String {
            switch self {
            case .upToDate: return "Up to Date"
            case .dueSoon: return "Due Soon"
            case .overdue: return "Overdue"
            }
        }

        var color: Color {
            switch self {
            case .upToDate: return .green
            case .dueSoon: return .orange
            case .overdue: return .red
            }
        }

        var icon: String {
            switch self {
            case .upToDate: return "checkmark.shield.fill"
            case .dueSoon: return "exclamationmark.shield.fill"
            case .overdue: return "xmark.shield.fill"
            }
        }
    }
}
