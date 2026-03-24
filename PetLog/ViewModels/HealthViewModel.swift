import Foundation
import SwiftData
import SwiftUI

enum HealthSection: String, CaseIterable, Identifiable {
    case overview, vetVisits, vaccinations, medications, weight
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .overview: return "Overview"
        case .vetVisits: return "Vet Visits"
        case .vaccinations: return "Vaccines"
        case .medications: return "Meds"
        case .weight: return "Weight"
        }
    }
}

@Observable
final class HealthViewModel {
    var selectedSection: HealthSection = .overview
    var showingAddVetVisit = false
    var showingAddVaccination = false
    var showingAddMedication = false
    var showingAddWeight = false

    func healthScore(for pet: Pet) -> Int {
        var score = 100
        let overdueVax = pet.overdueVaccinations.count
        score -= overdueVax * 15
        if pet.activeMedications.isEmpty == false {
            for med in pet.activeMedications where med.needsRefill {
                score -= 10
            }
        }
        if pet.weightEntries.isEmpty { score -= 5 }
        if pet.vetVisits.isEmpty { score -= 10 }
        return max(0, min(100, score))
    }

    func healthScoreColor(_ score: Int) -> Color {
        switch score {
        case 80...100: return .green
        case 60..<80: return .orange
        default: return .red
        }
    }

    func weightData(for pet: Pet, months: Int = 6) -> [(date: Date, weight: Double)] {
        let cutoff = Calendar.current.date(byAdding: .month, value: -months, to: Date())!
        return pet.weightEntries
            .filter { $0.date >= cutoff }
            .sorted { $0.date < $1.date }
            .map { (date: $0.date, weight: $0.weight) }
    }

    func sortedVetVisits(for pet: Pet) -> [VetVisit] {
        pet.vetVisits.sorted { $0.date > $1.date }
    }

    func sortedVaccinations(for pet: Pet) -> [Vaccination] {
        pet.vaccinations.sorted { ($0.nextDueDate ?? .distantFuture) < ($1.nextDueDate ?? .distantFuture) }
    }

    func activeMedications(for pet: Pet) -> [Medication] {
        pet.medications.filter { $0.isActive }.sorted { $0.name < $1.name }
    }

    func inactiveMedications(for pet: Pet) -> [Medication] {
        pet.medications.filter { !$0.isActive }.sorted { $0.name < $1.name }
    }
}
