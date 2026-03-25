import WidgetKit
import SwiftUI

// MARK: - Shared Defaults Reader (duplicated for widget target)

private enum WidgetSharedDefaults {
    static let suiteName = "group.com.petlog.shared"

    static var shared: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    static var petName: String {
        shared.string(forKey: "widget_petName") ?? "Your Pet"
    }

    static var petSpecies: String {
        shared.string(forKey: "widget_petSpecies") ?? "dog"
    }

    static var nextReminderTitle: String? {
        shared.string(forKey: "widget_nextReminderTitle")
    }

    static var nextReminderTime: Date? {
        shared.object(forKey: "widget_nextReminderTime") as? Date
    }

    static var nextReminderType: String? {
        shared.string(forKey: "widget_nextReminderType")
    }

    static var nextReminderPetName: String? {
        shared.string(forKey: "widget_nextReminderPetName")
    }

    static var upcomingRemindersCount: Int {
        shared.integer(forKey: "widget_upcomingRemindersCount")
    }

    static var lastFeedingTime: Date? {
        shared.object(forKey: "widget_lastFeedingTime") as? Date
    }

    static var currentWeight: String? {
        shared.string(forKey: "widget_currentWeight")
    }
}

// MARK: - Timeline Entry

struct PetLogEntry: TimelineEntry {
    let date: Date
    let petName: String
    let petSpecies: String
    let nextReminderTitle: String?
    let nextReminderTime: Date?
    let nextReminderType: String?
    let nextReminderPetName: String?
    let upcomingRemindersCount: Int
    let lastFeedingTime: Date?
    let currentWeight: String?

    static var placeholder: PetLogEntry {
        PetLogEntry(
            date: Date(),
            petName: "Buddy",
            petSpecies: "dog",
            nextReminderTitle: "Vet Checkup",
            nextReminderTime: Calendar.current.date(byAdding: .hour, value: 2, to: Date()),
            nextReminderType: "vet",
            nextReminderPetName: "Buddy",
            upcomingRemindersCount: 3,
            lastFeedingTime: Calendar.current.date(byAdding: .hour, value: -1, to: Date()),
            currentWeight: "25.0 lbs"
        )
    }
}

// MARK: - Timeline Provider

struct PetLogTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> PetLogEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (PetLogEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PetLogEntry>) -> Void) {
        let entry = currentEntry()
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func currentEntry() -> PetLogEntry {
        PetLogEntry(
            date: Date(),
            petName: WidgetSharedDefaults.petName,
            petSpecies: WidgetSharedDefaults.petSpecies,
            nextReminderTitle: WidgetSharedDefaults.nextReminderTitle,
            nextReminderTime: WidgetSharedDefaults.nextReminderTime,
            nextReminderType: WidgetSharedDefaults.nextReminderType,
            nextReminderPetName: WidgetSharedDefaults.nextReminderPetName,
            upcomingRemindersCount: WidgetSharedDefaults.upcomingRemindersCount,
            lastFeedingTime: WidgetSharedDefaults.lastFeedingTime,
            currentWeight: WidgetSharedDefaults.currentWeight
        )
    }
}

// MARK: - Helper: Reminder Type Icon

private func reminderTypeIcon(for type: String?) -> String {
    switch type {
    case "medication": return "pill.fill"
    case "vet": return "cross.case.fill"
    case "vaccination": return "syringe.fill"
    case "grooming": return "scissors"
    default: return "bell.fill"
    }
}

private func reminderTypeColor(for type: String?) -> Color {
    switch type {
    case "medication": return .blue
    case "vet": return .red
    case "vaccination": return .green
    case "grooming": return .purple
    default: return .orange
    }
}

private func speciesIcon(for species: String) -> String {
    switch species {
    case "dog": return "dog.fill"
    case "cat": return "cat.fill"
    case "bird": return "bird.fill"
    case "fish": return "fish.fill"
    case "rabbit": return "rabbit.fill"
    case "hamster": return "hare.fill"
    case "reptile": return "lizard.fill"
    default: return "pawprint.fill"
    }
}

// MARK: - Small Widget View

struct SmallWidgetView: View {
    let entry: PetLogEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: speciesIcon(for: entry.petSpecies))
                    .font(.caption2)
                    .foregroundStyle(Color(hex: "FF6B35"))
                Text("PetLog")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(Color(hex: "FF6B35"))
            }

            Spacer()

            if let title = entry.nextReminderTitle {
                // Has upcoming reminder
                Image(systemName: reminderTypeIcon(for: entry.nextReminderType))
                    .font(.title2)
                    .foregroundStyle(reminderTypeColor(for: entry.nextReminderType))

                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                if let time = entry.nextReminderTime {
                    Text(time, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if let petName = entry.nextReminderPetName {
                    Text(petName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else {
                // No reminders
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)

                Text("All Clear!")
                    .font(.subheadline.weight(.semibold))

                Text("No upcoming reminders")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Medium Widget View

struct MediumWidgetView: View {
    let entry: PetLogEntry

    private var lastFeedingFormatted: String {
        guard let time = entry.lastFeedingTime else { return "—" }
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: time)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: speciesIcon(for: entry.petSpecies))
                        .foregroundStyle(Color(hex: "FF6B35"))
                    Text(entry.petName)
                        .font(.subheadline.weight(.bold))
                }

                Spacer()

                Text("Today")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Stats row
            HStack(spacing: 0) {
                // Reminders
                statBlock(
                    icon: "bell.fill",
                    color: .orange,
                    value: "\(entry.upcomingRemindersCount)",
                    label: "Reminders"
                )

                Divider()
                    .frame(height: 36)

                // Last Feeding
                statBlock(
                    icon: "takeoutbag.and.cup.and.straw.fill",
                    color: Color(hex: "2EC4B6"),
                    value: lastFeedingFormatted,
                    label: "Last Fed"
                )

                Divider()
                    .frame(height: 36)

                // Weight
                statBlock(
                    icon: "scalemass.fill",
                    color: .purple,
                    value: entry.currentWeight ?? "—",
                    label: "Weight"
                )
            }

            // Next reminder preview
            if let title = entry.nextReminderTitle,
               let time = entry.nextReminderTime {
                HStack(spacing: 8) {
                    Image(systemName: reminderTypeIcon(for: entry.nextReminderType))
                        .font(.caption)
                        .foregroundStyle(reminderTypeColor(for: entry.nextReminderType))
                        .frame(width: 20)

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Next: \(title)")
                            .font(.caption.weight(.medium))
                            .lineLimit(1)
                        Text(time, style: .relative)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.systemGray6).opacity(0.8), in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func statBlock(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Color Hex (for widget target)

private extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Widget Configuration

struct PetLogWidget: Widget {
    let kind: String = "PetLogWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PetLogTimelineProvider()) { entry in
            Group {
                if #available(iOSApplicationExtension 17.0, *) {
                    PetLogWidgetEntryView(entry: entry)
                        .containerBackground(.fill.tertiary, for: .widget)
                } else {
                    PetLogWidgetEntryView(entry: entry)
                        .padding()
                        .background()
                }
            }
        }
        .configurationDisplayName("PetLog")
        .description("Keep track of your pet's reminders, feedings, and health at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PetLogWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PetLogEntry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Bundle

@main
struct PetLogWidgetBundle: WidgetBundle {
    var body: some Widget {
        PetLogWidget()
    }
}

// MARK: - Previews

#Preview("Small", as: .systemSmall) {
    PetLogWidget()
} timeline: {
    PetLogEntry.placeholder
}

#Preview("Medium", as: .systemMedium) {
    PetLogWidget()
} timeline: {
    PetLogEntry.placeholder
}
