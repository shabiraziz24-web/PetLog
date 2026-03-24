import SwiftUI
import SwiftData

struct AddVetVisitView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var vetName = ""
    @State private var clinicName = ""
    @State private var clinicAddress = ""
    @State private var clinicPhone = ""
    @State private var reason = ""
    @State private var diagnosis = ""
    @State private var treatment = ""
    @State private var notes = ""
    @State private var cost = ""
    @State private var hasFollowUp = false
    @State private var followUpDate = Date()

    var body: some View {
        NavigationStack {
            Form {
                Section("Visit Details") {
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField("Reason for Visit", text: $reason)
                }

                Section("Clinic") {
                    TextField("Vet Name", text: $vetName)
                    TextField("Clinic Name", text: $clinicName)
                    TextField("Address", text: $clinicAddress)
                    TextField("Phone", text: $clinicPhone)
                        .keyboardType(.phonePad)
                }

                Section("Medical Details") {
                    TextField("Diagnosis", text: $diagnosis)
                    TextField("Treatment", text: $treatment)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section("Cost & Follow-up") {
                    TextField("Cost", text: $cost)
                        .keyboardType(.decimalPad)

                    Toggle("Follow-up Needed", isOn: $hasFollowUp)
                    if hasFollowUp {
                        DatePicker("Follow-up Date", selection: $followUpDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("Add Vet Visit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(reason.isEmpty)
                }
            }
        }
    }

    private func save() {
        let visit = VetVisit(
            date: date,
            vetName: vetName,
            clinicName: clinicName,
            clinicAddress: clinicAddress,
            clinicPhone: clinicPhone,
            reason: reason,
            diagnosis: diagnosis,
            treatment: treatment,
            notes: notes,
            cost: Double(cost),
            followUpDate: hasFollowUp ? followUpDate : nil,
            pet: pet
        )
        modelContext.insert(visit)
        NotificationService.shared.scheduleVetReminder(vetVisit: visit, pet: pet)
        HapticManager.notification(.success)
        dismiss()
    }
}
