import SwiftUI
import SwiftData

struct AddFeedingLogView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var time = Date()
    @State private var foodBrand = ""
    @State private var foodType: FoodType = .dry
    @State private var amount = ""
    @State private var unit = "cups"
    @State private var calories = ""
    @State private var notes = ""

    private let units = ["cups", "oz", "g", "ml", "pieces", "tbsp"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Meal") {
                    Picker("Food Type", selection: $foodType) {
                        ForEach(FoodType.allCases) { type in
                            Label(type.displayName, systemImage: type.icon).tag(type)
                        }
                    }
                    TextField("Food Brand", text: $foodBrand)
                }

                Section("Amount") {
                    HStack {
                        TextField("Amount", text: $amount)
                            .keyboardType(.decimalPad)
                        Picker("Unit", selection: $unit) {
                            ForEach(units, id: \.self) { u in
                                Text(u).tag(u)
                            }
                        }
                    }
                    TextField("Calories (optional)", text: $calories)
                        .keyboardType(.numberPad)
                }

                Section("When") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                }

                Section("Notes") {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Log Feeding")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func save() {
        let log = FeedingLog(
            date: date,
            time: time,
            foodBrand: foodBrand,
            foodType: foodType,
            amount: Double(amount),
            unit: unit,
            calories: Int(calories),
            notes: notes,
            pet: pet
        )
        modelContext.insert(log)
        HapticManager.notification(.success)
        dismiss()
    }
}
