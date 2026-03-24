import SwiftUI
import SwiftData
import PhotosUI

struct AddExpenseView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var category: ExpenseCategory = .food
    @State private var description = ""
    @State private var amount = ""
    @State private var vendor = ""
    @State private var isRecurring = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var receiptData: Data?

    var body: some View {
        NavigationStack {
            Form {
                Section("Expense") {
                    Picker("Category", selection: $category) {
                        ForEach(ExpenseCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.icon).tag(cat)
                        }
                    }
                    TextField("Description", text: $description)
                    TextField("Amount", text: $amount)
                        .keyboardType(.decimalPad)
                }

                Section("Details") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    TextField("Vendor", text: $vendor)
                    Toggle("Recurring Expense", isOn: $isRecurring)
                }

                Section("Receipt") {
                    PhotosPicker(selection: $selectedPhoto, matching: .images) {
                        if receiptData != nil {
                            Label("Receipt Attached", systemImage: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        } else {
                            Label("Attach Receipt Photo", systemImage: "camera.fill")
                        }
                    }
                    .onChange(of: selectedPhoto) {
                        Task {
                            if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                                receiptData = data
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(amount.isEmpty)
                }
            }
        }
    }

    private func save() {
        guard let amountValue = Double(amount) else { return }
        let expense = Expense(
            date: date,
            category: category,
            expenseDescription: description,
            amount: amountValue,
            receiptPhoto: receiptData,
            vendor: vendor,
            isRecurring: isRecurring,
            pet: pet
        )
        modelContext.insert(expense)
        HapticManager.notification(.success)
        dismiss()
    }
}
