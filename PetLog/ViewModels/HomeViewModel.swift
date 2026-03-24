import Foundation
import SwiftData
import SwiftUI

@Observable
final class HomeViewModel {
    var selectedPet: Pet?
    var showingAddPet = false
    var showingQuickAdd = false

    func selectPet(_ pet: Pet) {
        selectedPet = pet
        UserDefaults.standard.set(pet.id.uuidString, forKey: Constants.UserDefaultsKeys.selectedPetId)
        HapticManager.selection()
    }

    func loadSelectedPet(from pets: [Pet]) {
        if selectedPet == nil {
            if let savedId = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.selectedPetId),
               let uuid = UUID(uuidString: savedId),
               let pet = pets.first(where: { $0.id == uuid }) {
                selectedPet = pet
            } else {
                selectedPet = pets.first
            }
        }
    }

    func upcomingReminders(for pet: Pet) -> [Reminder] {
        pet.reminders
            .filter { !$0.isCompleted && $0.isDueThisWeek }
            .sorted { $0.date < $1.date }
            .prefix(5)
            .map { $0 }
    }

    func recentJournalEntries(for pet: Pet) -> [JournalEntry] {
        pet.journalEntries
            .sorted { $0.date > $1.date }
            .prefix(3)
            .map { $0 }
    }

    func monthlyExpenseTotal(for pet: Pet) -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        return pet.expenses
            .filter { $0.date >= startOfMonth }
            .reduce(0) { $0 + $1.amount }
    }

    func expensesByCategory(for pet: Pet) -> [(category: ExpenseCategory, amount: Double)] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let monthExpenses = pet.expenses.filter { $0.date >= startOfMonth }

        var categoryTotals: [ExpenseCategory: Double] = [:]
        for expense in monthExpenses {
            categoryTotals[expense.category, default: 0] += expense.amount
        }

        return categoryTotals
            .map { (category: $0.key, amount: $0.value) }
            .sorted { $0.amount > $1.amount }
    }
}
