import Foundation
import SwiftData
import SwiftUI

enum Species: String, Codable, CaseIterable, Identifiable {
    case dog, cat, bird, fish, rabbit, hamster, reptile, other
    var id: String { rawValue }

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .dog: return "dog.fill"
        case .cat: return "cat.fill"
        case .bird: return "bird.fill"
        case .fish: return "fish.fill"
        case .rabbit: return "rabbit.fill"
        case .hamster: return "hare.fill"
        case .reptile: return "lizard.fill"
        case .other: return "pawprint.fill"
        }
    }

    var accentColor: Color {
        switch self {
        case .dog: return Color(hex: "FF6B35")
        case .cat: return .purple
        case .bird: return .green
        case .fish: return .blue
        case .rabbit: return .pink
        case .hamster: return .orange
        case .reptile: return .mint
        case .other: return .gray
        }
    }
}

enum PetGender: String, Codable, CaseIterable, Identifiable {
    case male, female, unknown
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
}

@Model
final class Pet {
    var id: UUID
    var name: String
    var species: Species
    var breed: String
    var birthDate: Date?
    var adoptionDate: Date?
    var gender: PetGender
    var weight: Double?
    var color: String
    var microchipNumber: String
    @Attribute(.externalStorage) var photo: Data?
    var isNeutered: Bool
    var bloodType: String
    var allergies: [String]
    var notes: String
    var createdAt: Date
    var updatedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \VetVisit.pet) var vetVisits: [VetVisit]
    @Relationship(deleteRule: .cascade, inverse: \Vaccination.pet) var vaccinations: [Vaccination]
    @Relationship(deleteRule: .cascade, inverse: \Medication.pet) var medications: [Medication]
    @Relationship(deleteRule: .cascade, inverse: \WeightEntry.pet) var weightEntries: [WeightEntry]
    @Relationship(deleteRule: .cascade, inverse: \FeedingLog.pet) var feedingLogs: [FeedingLog]
    @Relationship(deleteRule: .cascade, inverse: \PetActivity.pet) var activities: [PetActivity]
    @Relationship(deleteRule: .cascade, inverse: \Expense.pet) var expenses: [Expense]
    @Relationship(deleteRule: .cascade, inverse: \JournalEntry.pet) var journalEntries: [JournalEntry]
    @Relationship(deleteRule: .cascade, inverse: \Reminder.pet) var reminders: [Reminder]
    @Relationship(deleteRule: .cascade, inverse: \PetPhoto.pet) var photos: [PetPhoto]

    init(
        name: String = "",
        species: Species = .dog,
        breed: String = "",
        birthDate: Date? = nil,
        adoptionDate: Date? = nil,
        gender: PetGender = .unknown,
        weight: Double? = nil,
        color: String = "",
        microchipNumber: String = "",
        photo: Data? = nil,
        isNeutered: Bool = false,
        bloodType: String = "",
        allergies: [String] = [],
        notes: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.species = species
        self.breed = breed
        self.birthDate = birthDate
        self.adoptionDate = adoptionDate
        self.gender = gender
        self.weight = weight
        self.color = color
        self.microchipNumber = microchipNumber
        self.photo = photo
        self.isNeutered = isNeutered
        self.bloodType = bloodType
        self.allergies = allergies
        self.notes = notes
        self.createdAt = Date()
        self.updatedAt = Date()
        self.vetVisits = []
        self.vaccinations = []
        self.medications = []
        self.weightEntries = []
        self.feedingLogs = []
        self.activities = []
        self.expenses = []
        self.journalEntries = []
        self.reminders = []
        self.photos = []
    }

    var age: String {
        guard let birthDate else { return "Unknown" }
        let components = Calendar.current.dateComponents([.year, .month], from: birthDate, to: Date())
        if let years = components.year, years > 0 {
            let months = components.month ?? 0
            return months > 0 ? "\(years)y \(months)m" : "\(years)y"
        } else if let months = components.month, months > 0 {
            return "\(months)m"
        }
        return "< 1m"
    }

    var activeMedications: [Medication] {
        medications.filter { $0.isActive }
    }

    var nextVetVisit: VetVisit? {
        vetVisits
            .filter { $0.date > Date() }
            .sorted { $0.date < $1.date }
            .first
    }

    var overdueVaccinations: [Vaccination] {
        vaccinations.filter { vax in
            guard let dueDate = vax.nextDueDate else { return false }
            return dueDate < Date()
        }
    }

    var latestWeight: WeightEntry? {
        weightEntries.sorted { $0.date > $1.date }.first
    }

    var weightTrend: WeightTrend {
        let sorted = weightEntries.sorted { $0.date < $1.date }
        guard sorted.count >= 2 else { return .stable }
        let last = sorted[sorted.count - 1].weight
        let prev = sorted[sorted.count - 2].weight
        if last > prev + 0.5 { return .up }
        if last < prev - 0.5 { return .down }
        return .stable
    }

    var recentPhotos: [PetPhoto] {
        photos.sorted { $0.date > $1.date }.prefix(4).map { $0 }
    }

    enum WeightTrend {
        case up, down, stable
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }
        var color: Color {
            switch self {
            case .up: return .orange
            case .down: return .blue
            case .stable: return .green
            }
        }
    }
}
