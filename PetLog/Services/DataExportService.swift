import Foundation
import SwiftUI

final class DataExportService {
    static let shared = DataExportService()

    private init() {}

    func exportExpensesCSV(expenses: [Expense]) -> URL? {
        var csv = "Date,Category,Description,Amount,Currency,Vendor,Recurring\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for expense in expenses.sorted(by: { $0.date > $1.date }) {
            let date = dateFormatter.string(from: expense.date)
            let category = expense.category.displayName
            let desc = expense.expenseDescription.replacingOccurrences(of: ",", with: ";")
            let amount = String(format: "%.2f", expense.amount)
            let currency = expense.currency
            let vendor = expense.vendor.replacingOccurrences(of: ",", with: ";")
            let recurring = expense.isRecurring ? "Yes" : "No"
            csv += "\(date),\(category),\(desc),\(amount),\(currency),\(vendor),\(recurring)\n"
        }

        return writeToTempFile(content: csv, filename: "PetLog_Expenses.csv")
    }

    func exportVetVisitsCSV(visits: [VetVisit]) -> URL? {
        var csv = "Date,Vet,Clinic,Reason,Diagnosis,Treatment,Cost\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for visit in visits.sorted(by: { $0.date > $1.date }) {
            let date = dateFormatter.string(from: visit.date)
            let vet = visit.vetName.replacingOccurrences(of: ",", with: ";")
            let clinic = visit.clinicName.replacingOccurrences(of: ",", with: ";")
            let reason = visit.reason.replacingOccurrences(of: ",", with: ";")
            let diagnosis = visit.diagnosis.replacingOccurrences(of: ",", with: ";")
            let treatment = visit.treatment.replacingOccurrences(of: ",", with: ";")
            let cost = visit.cost.map { String(format: "%.2f", $0) } ?? ""
            csv += "\(date),\(vet),\(clinic),\(reason),\(diagnosis),\(treatment),\(cost)\n"
        }

        return writeToTempFile(content: csv, filename: "PetLog_VetVisits.csv")
    }

    func exportWeightCSV(entries: [WeightEntry]) -> URL? {
        var csv = "Date,Weight,Unit,Notes\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        for entry in entries.sorted(by: { $0.date > $1.date }) {
            let date = dateFormatter.string(from: entry.date)
            let weight = String(format: "%.1f", entry.weight)
            let unit = entry.unit.displayName
            let notes = entry.notes.replacingOccurrences(of: ",", with: ";")
            csv += "\(date),\(weight),\(unit),\(notes)\n"
        }

        return writeToTempFile(content: csv, filename: "PetLog_Weight.csv")
    }

    func exportAllDataCSV(pet: Pet) -> URL? {
        var csv = "=== PET PROFILE ===\n"
        csv += "Name,\(pet.name)\n"
        csv += "Species,\(pet.species.displayName)\n"
        csv += "Breed,\(pet.breed)\n"
        csv += "Age,\(pet.age)\n\n"

        csv += "=== VET VISITS ===\n"
        csv += "Date,Vet,Clinic,Reason,Diagnosis,Cost\n"
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        for visit in pet.vetVisits.sorted(by: { $0.date > $1.date }) {
            csv += "\(df.string(from: visit.date)),\(visit.vetName),\(visit.clinicName),\(visit.reason),\(visit.diagnosis),\(visit.cost.map { String(format: "%.2f", $0) } ?? "")\n"
        }

        csv += "\n=== MEDICATIONS ===\n"
        csv += "Name,Dosage,Frequency,Active\n"
        for med in pet.medications {
            csv += "\(med.name),\(med.dosage),\(med.frequency.displayName),\(med.isActive ? "Yes" : "No")\n"
        }

        csv += "\n=== VACCINATIONS ===\n"
        csv += "Name,Date,Next Due,Status\n"
        for vax in pet.vaccinations {
            csv += "\(vax.name),\(df.string(from: vax.dateAdministered)),\(vax.nextDueDate.map { df.string(from: $0) } ?? "N/A"),\(vax.status.label)\n"
        }

        return writeToTempFile(content: csv, filename: "PetLog_\(pet.name)_AllData.csv")
    }

    private func writeToTempFile(content: String, filename: String) -> URL? {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(filename)
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to write CSV: \(error)")
            return nil
        }
    }
}
