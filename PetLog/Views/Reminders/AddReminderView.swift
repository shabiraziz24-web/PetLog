import SwiftUI
import SwiftData

struct AddReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let pet: Pet

    @State private var title = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var type: ReminderType = .other
    @State private var repeatInterval: RepeatInterval = .none
    @State private var notes = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminder Details") {
                    TextField("Title", text: $title)

                    Picker("Type", selection: $type) {
                        ForEach(ReminderType.allCases) { reminderType in
                            Label(reminderType.displayName, systemImage: reminderType.icon)
                                .tag(reminderType)
                        }
                    }
                }

                Section("When") {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                }

                Section("Repeat") {
                    Picker("Repeat", selection: $repeatInterval) {
                        ForEach(RepeatInterval.allCases) { interval in
                            Text(interval.displayName).tag(interval)
                        }
                    }
                }
            }
            .navigationTitle("Add Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReminder()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveReminder() {
        let reminder = Reminder(
            title: title,
            date: date,
            time: time,
            repeatInterval: repeatInterval,
            type: type,
            pet: pet
        )
        modelContext.insert(reminder)
        dismiss()
    }
}

#Preview {
    AddReminderView(pet: Pet(name: "Buddy", species: .dog))
        .modelContainer(for: Reminder.self, inMemory: true)
}
