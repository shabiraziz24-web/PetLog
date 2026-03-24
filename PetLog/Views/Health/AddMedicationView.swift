import SwiftUI
import SwiftData

struct AddMedicationView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var dosage = ""
    @State private var frequency: MedicationFrequency = .daily
    @State private var startDate = Date()
    @State private var hasEndDate = false
    @State private var endDate = Date()
    @State private var timeOfDay = Date()
    @State private var instructions = ""
    @State private var hasRefillDate = false
    @State private var refillDate = Date()
    @State private var prescribedBy = ""
    @State private var cost = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Medication") {
                    TextField("Name", text: $name)
                    TextField("Dosage (e.g., 50mg)", text: $dosage)
                    Picker("Frequency", selection: $frequency) {
                        ForEach(MedicationFrequency.allCases) { freq in
                            Text(freq.displayName).tag(freq)
                        }
                    }
                }

                Section("Schedule") {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    Toggle("Has End Date", isOn: $hasEndDate)
                    if hasEndDate {
                        DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                    }
                    if frequency != .asNeeded {
                        DatePicker("Time of Day", selection: $timeOfDay, displayedComponents: .hourAndMinute)
                    }
                }

                Section("Details") {
                    TextField("Instructions", text: $instructions, axis: .vertical)
                        .lineLimit(2...4)
                    TextField("Prescribed By", text: $prescribedBy)
                    TextField("Cost", text: $cost)
                        .keyboardType(.decimalPad)
                }

                Section("Refill") {
                    Toggle("Track Refill Date", isOn: $hasRefillDate)
                    if hasRefillDate {
                        DatePicker("Refill Date", selection: $refillDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Add Medication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(name.isEmpty)
                }
            }
        }
    }

    private func save() {
        let medication = Medication(
            name: name,
            dosage: dosage,
            frequency: frequency,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil,
            timeOfDay: frequency != .asNeeded ? timeOfDay : nil,
            instructions: instructions,
            refillDate: hasRefillDate ? refillDate : nil,
            prescribedBy: prescribedBy,
            cost: Double(cost),
            isActive: true,
            pet: pet
        )
        modelContext.insert(medication)
        NotificationService.shared.scheduleMedicationReminder(medication: medication, pet: pet)
        HapticManager.notification(.success)
        dismiss()
    }
}
