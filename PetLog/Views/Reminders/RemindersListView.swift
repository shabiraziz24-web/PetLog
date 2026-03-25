import SwiftUI
import SwiftData

struct RemindersListView: View {
    @Query(sort: \Reminder.date) private var reminders: [Reminder]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        List {
            if reminders.isEmpty {
                EmptyStateView(
                    icon: "bell.slash",
                    title: "No Reminders",
                    message: "Add reminders for medications, vet visits, and more."
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
            } else {
                ForEach(reminders) { reminder in
                    ReminderRow(reminder: reminder)
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        modelContext.delete(reminders[index])
                    }
                    try? modelContext.save()
                }
            }
        }
        .navigationTitle("Reminders")
    }
}

private struct ReminderRow: View {
    let reminder: Reminder

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: reminder.isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(reminder.isCompleted ? .green : .secondary)
                .font(.title3)

            VStack(alignment: .leading, spacing: 4) {
                Text(reminder.title)
                    .font(.subheadline.weight(.medium))
                    .strikethrough(reminder.isCompleted)

                Text(reminder.date.shortDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Reminder View

struct AddReminderView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let pet: Pet

    @State private var title = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var type: ReminderType = .other
    @State private var repeatInterval: RepeatInterval = .none

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
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        RemindersListView()
    }
    .modelContainer(for: Reminder.self, inMemory: true)
}
