import SwiftUI
import SwiftData

struct AddActivityView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var date = Date()
    @State private var type: ActivityType = .walk
    @State private var hours = 0
    @State private var minutes = 30
    @State private var distance = ""
    @State private var calories = ""
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Activity") {
                    Picker("Type", selection: $type) {
                        ForEach(ActivityType.allCases) { t in
                            Label(t.displayName, systemImage: t.icon).tag(t)
                        }
                    }
                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Duration") {
                    HStack {
                        Picker("Hours", selection: $hours) {
                            ForEach(0..<24) { h in
                                Text("\(h)h").tag(h)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)

                        Picker("Minutes", selection: $minutes) {
                            ForEach(0..<60) { m in
                                Text("\(m)m").tag(m)
                            }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 100)
                    }
                    .frame(height: 100)
                }

                Section("Details") {
                    TextField("Distance (miles)", text: $distance)
                        .keyboardType(.decimalPad)
                    TextField("Calories Burned", text: $calories)
                        .keyboardType(.numberPad)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Add Activity")
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
        let duration = TimeInterval(hours * 3600 + minutes * 60)
        let activity = PetActivity(
            date: date,
            type: type,
            duration: duration,
            distance: Double(distance),
            calories: Int(calories),
            notes: notes,
            pet: pet
        )
        modelContext.insert(activity)
        HapticManager.notification(.success)
        dismiss()
    }
}
