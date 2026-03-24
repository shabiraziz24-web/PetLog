import SwiftUI
import SwiftData

struct AddWeightEntryView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var weight = ""
    @State private var unit: WeightUnit = .lb
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Weight") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)

                    HStack {
                        TextField("Weight", text: $weight)
                            .keyboardType(.decimalPad)

                        Picker("Unit", selection: $unit) {
                            ForEach(WeightUnit.allCases) { u in
                                Text(u.displayName).tag(u)
                            }
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }
                }

                Section("Notes") {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }

                if let previousWeight = pet.latestWeight {
                    Section("Previous Entry") {
                        HStack {
                            Text(previousWeight.date.shortDate)
                            Spacer()
                            Text(previousWeight.weightFormatted)
                                .fontWeight(.medium)
                        }
                    }
                }
            }
            .navigationTitle("Log Weight")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(weight.isEmpty)
                }
            }
        }
    }

    private func save() {
        guard let weightValue = Double(weight) else { return }
        let entry = WeightEntry(
            date: date,
            weight: weightValue,
            unit: unit,
            notes: notes,
            pet: pet
        )
        modelContext.insert(entry)
        pet.weight = weightValue
        HapticManager.notification(.success)
        dismiss()
    }
}
