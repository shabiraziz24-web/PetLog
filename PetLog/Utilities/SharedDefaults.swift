import Foundation

enum SharedDefaults {
    static let suiteName = "group.com.petlog.shared"

    static var shared: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }

    // MARK: - Keys

    enum Keys {
        static let petName = "widget_petName"
        static let petSpecies = "widget_petSpecies"
        static let nextReminderTitle = "widget_nextReminderTitle"
        static let nextReminderTime = "widget_nextReminderTime"
        static let nextReminderType = "widget_nextReminderType"
        static let nextReminderPetName = "widget_nextReminderPetName"
        static let upcomingRemindersCount = "widget_upcomingRemindersCount"
        static let lastFeedingTime = "widget_lastFeedingTime"
        static let currentWeight = "widget_currentWeight"
        static let lastUpdated = "widget_lastUpdated"
    }

    // MARK: - Write (from main app)

    static func updateWidgetData(
        petName: String,
        petSpecies: String,
        nextReminderTitle: String?,
        nextReminderTime: Date?,
        nextReminderType: String?,
        nextReminderPetName: String?,
        upcomingRemindersCount: Int,
        lastFeedingTime: Date?,
        currentWeight: String?
    ) {
        let defaults = shared
        defaults.set(petName, forKey: Keys.petName)
        defaults.set(petSpecies, forKey: Keys.petSpecies)
        defaults.set(nextReminderTitle, forKey: Keys.nextReminderTitle)
        defaults.set(nextReminderTime, forKey: Keys.nextReminderTime)
        defaults.set(nextReminderType, forKey: Keys.nextReminderType)
        defaults.set(nextReminderPetName, forKey: Keys.nextReminderPetName)
        defaults.set(upcomingRemindersCount, forKey: Keys.upcomingRemindersCount)
        defaults.set(lastFeedingTime, forKey: Keys.lastFeedingTime)
        defaults.set(currentWeight, forKey: Keys.currentWeight)
        defaults.set(Date(), forKey: Keys.lastUpdated)
    }

    // MARK: - Read (from widget)

    static var petName: String {
        shared.string(forKey: Keys.petName) ?? "Your Pet"
    }

    static var petSpecies: String {
        shared.string(forKey: Keys.petSpecies) ?? "dog"
    }

    static var nextReminderTitle: String? {
        shared.string(forKey: Keys.nextReminderTitle)
    }

    static var nextReminderTime: Date? {
        shared.object(forKey: Keys.nextReminderTime) as? Date
    }

    static var nextReminderType: String? {
        shared.string(forKey: Keys.nextReminderType)
    }

    static var nextReminderPetName: String? {
        shared.string(forKey: Keys.nextReminderPetName)
    }

    static var upcomingRemindersCount: Int {
        shared.integer(forKey: Keys.upcomingRemindersCount)
    }

    static var lastFeedingTime: Date? {
        shared.object(forKey: Keys.lastFeedingTime) as? Date
    }

    static var currentWeight: String? {
        shared.string(forKey: Keys.currentWeight)
    }
}
