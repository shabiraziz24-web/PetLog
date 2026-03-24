import Foundation
import SwiftData
import SwiftUI

enum RepeatInterval: String, Codable, CaseIterable, Identifiable {
    case none, daily, weekly, monthly, yearly
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

enum ReminderType: String, Codable, CaseIterable, Identifiable {
    case medication, vet, vaccination, grooming, other
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .medication: return "pill.fill"
        case .vet: return "cross.case.fill"
        case .vaccination: return "syringe.fill"
        case .grooming: return "scissors"
        case .other: return "bell.fill"
        }
    }
    var color: Color {
        switch self {
        case .medication: return .blue
        case .vet: return .red
        case .vaccination: return .green
        case .grooming: return .purple
        case .other: return .orange
        }
    }
}

@Model
final class Reminder {
    var id: UUID
    var title: String
    var date: Date
    var time: Date
    var repeatInterval: RepeatInterval
    var type: ReminderType
    var isCompleted: Bool
    var createdAt: Date

    var pet: Pet?

    init(
        title: String = "",
        date: Date = Date(),
        time: Date = Date(),
        repeatInterval: RepeatInterval = .none,
        type: ReminderType = .other,
        isCompleted: Bool = false,
        pet: Pet? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.date = date
        self.time = time
        self.repeatInterval = repeatInterval
        self.type = type
        self.isCompleted = isCompleted
        self.createdAt = Date()
        self.pet = pet
    }

    var isOverdue: Bool {
        !isCompleted && date < Date()
    }

    var isDueToday: Bool {
        Calendar.current.isDateInToday(date)
    }

    var isDueThisWeek: Bool {
        let calendar = Calendar.current
        let now = Date()
        let weekFromNow = calendar.date(byAdding: .weekOfYear, value: 1, to: now)!
        return date >= now && date <= weekFromNow
    }

    var timeFormatted: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }
}
