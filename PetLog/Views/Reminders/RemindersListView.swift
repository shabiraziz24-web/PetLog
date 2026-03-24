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

#Preview {
    NavigationStack {
        RemindersListView()
    }
    .modelContainer(for: Reminder.self, inMemory: true)
}
