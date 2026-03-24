import Foundation
import SwiftData
import SwiftUI

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
    case food, medical, grooming, toys, boarding, insurance, other
    var id: String { rawValue }
    var displayName: String { rawValue.capitalized }
    var icon: String {
        switch self {
        case .food: return "cart.fill"
        case .medical: return "cross.case.fill"
        case .grooming: return "scissors"
        case .toys: return "teddybear.fill"
        case .boarding: return "house.fill"
        case .insurance: return "shield.checkered"
        case .other: return "ellipsis.circle.fill"
        }
    }
    var color: Color {
        switch self {
        case .food: return .orange
        case .medical: return .red
        case .grooming: return .purple
        case .toys: return .green
        case .boarding: return .blue
        case .insurance: return .teal
        case .other: return .gray
        }
    }
}

@Model
final class Expense {
    var id: UUID
    var date: Date
    var category: ExpenseCategory
    var expenseDescription: String
    var amount: Double
    var currency: String
    @Attribute(.externalStorage) var receiptPhoto: Data?
    var vendor: String
    var isRecurring: Bool
    var createdAt: Date

    var pet: Pet?

    init(
        date: Date = Date(),
        category: ExpenseCategory = .food,
        expenseDescription: String = "",
        amount: Double = 0,
        currency: String = "USD",
        receiptPhoto: Data? = nil,
        vendor: String = "",
        isRecurring: Bool = false,
        pet: Pet? = nil
    ) {
        self.id = UUID()
        self.date = date
        self.category = category
        self.expenseDescription = expenseDescription
        self.amount = amount
        self.currency = currency
        self.receiptPhoto = receiptPhoto
        self.vendor = vendor
        self.isRecurring = isRecurring
        self.createdAt = Date()
        self.pet = pet
    }

    var amountFormatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "$\(amount)"
    }
}
