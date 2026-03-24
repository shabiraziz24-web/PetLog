import SwiftUI
import SwiftData

struct AddVaccinationView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var dateAdministered = Date()
    @State private var hasNextDue = true
    @State private var nextDueDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())!
    @State private var vetName = ""
    @State private var batchNumber = ""
    @State private var notes = ""

    private let commonVaccinations: [String] = {
        return [
            "Rabies", "DHPP (Distemper)", "Bordetella", "Leptospirosis",
            "Canine Influenza", "Lyme Disease", "FVRCP", "FeLV",
            "FIV", "Avian Polyomavirus", "Newcastle Disease"
        ]
    }()

    var body: some View {
        NavigationStack {
            Form {
                Section("Vaccination") {
                    TextField("Vaccination Name", text: $name)

                    if name.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(commonVaccinations, id: \.self) { vax in
                                    Button(vax) {
                                        name = vax
                                    }
                                    .buttonStyle(.bordered)
                                    .buttonBorderShape(.capsule)
                                    .tint(Theme.secondaryColor)
                                }
                            }
                        }
                    }
                }

                Section("Dates") {
                    DatePicker("Date Administered", selection: $dateAdministered, displayedComponents: .date)
                    Toggle("Has Next Due Date", isOn: $hasNextDue)
                    if hasNextDue {
                        DatePicker("Next Due Date", selection: $nextDueDate, displayedComponents: .date)
                    }
                }

                Section("Details") {
                    TextField("Vet Name", text: $vetName)
                    TextField("Batch Number", text: $batchNumber)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Add Vaccination")
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
        let vaccination = Vaccination(
            name: name,
            dateAdministered: dateAdministered,
            nextDueDate: hasNextDue ? nextDueDate : nil,
            vetName: vetName,
            batchNumber: batchNumber,
            notes: notes,
            pet: pet
        )
        modelContext.insert(vaccination)
        NotificationService.shared.scheduleVaccinationReminder(vaccination: vaccination, pet: pet)
        HapticManager.notification(.success)
        dismiss()
    }
}
