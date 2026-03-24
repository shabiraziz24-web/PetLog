import Foundation
import UserNotifications

@Observable
final class NotificationService {
    static let shared = NotificationService()
    var isAuthorized = false

    private init() {}

    func requestAuthorization() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            await MainActor.run { isAuthorized = granted }
            if granted { setupCategories() }
        } catch {
            print("Notification authorization error: \(error)")
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        await MainActor.run {
            isAuthorized = settings.authorizationStatus == .authorized
        }
    }

    private func setupCategories() {
        let takeMedicationAction = UNNotificationAction(
            identifier: "TAKE_MEDICATION",
            title: "Mark as Taken",
            options: .foreground
        )
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_15",
            title: "Snooze 15 min",
            options: []
        )
        let medicationCategory = UNNotificationCategory(
            identifier: "MEDICATION_REMINDER",
            actions: [takeMedicationAction, snoozeAction],
            intentIdentifiers: []
        )

        let confirmAction = UNNotificationAction(
            identifier: "CONFIRM_VET",
            title: "Confirmed",
            options: .foreground
        )
        let vetCategory = UNNotificationCategory(
            identifier: "VET_REMINDER",
            actions: [confirmAction, snoozeAction],
            intentIdentifiers: []
        )

        let vaccinationCategory = UNNotificationCategory(
            identifier: "VACCINATION_REMINDER",
            actions: [confirmAction],
            intentIdentifiers: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([
            medicationCategory, vetCategory, vaccinationCategory
        ])
    }

    // MARK: - Schedule Notifications

    func scheduleMedicationReminder(medication: Medication, pet: Pet) {
        guard let timeOfDay = medication.timeOfDay else { return }
        let content = UNMutableNotificationContent()
        content.title = "💊 Medication Reminder"
        content.body = "Time to give \(pet.name) their \(medication.name) (\(medication.dosage))"
        content.sound = .default
        content.categoryIdentifier = "MEDICATION_REMINDER"

        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.hour, .minute], from: timeOfDay)

        let trigger: UNNotificationTrigger
        switch medication.frequency {
        case .daily:
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .weekly:
            dateComponents.weekday = calendar.component(.weekday, from: medication.startDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .monthly:
            dateComponents.day = calendar.component(.day, from: medication.startDate)
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        case .asNeeded:
            return
        }

        let request = UNNotificationRequest(
            identifier: "medication-\(medication.id)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleVetReminder(vetVisit: VetVisit, pet: Pet) {
        // 1 day before
        let dayBefore = Calendar.current.date(byAdding: .day, value: -1, to: vetVisit.date)!
        scheduleOneTimeNotification(
            id: "vet-day-\(vetVisit.id)",
            title: "🏥 Vet Visit Tomorrow",
            body: "\(pet.name) has a vet appointment tomorrow at \(vetVisit.clinicName)",
            date: dayBefore,
            category: "VET_REMINDER"
        )

        // 2 hours before
        let hoursBefore = Calendar.current.date(byAdding: .hour, value: -2, to: vetVisit.date)!
        scheduleOneTimeNotification(
            id: "vet-hour-\(vetVisit.id)",
            title: "🏥 Vet Visit in 2 Hours",
            body: "\(pet.name)'s appointment at \(vetVisit.clinicName) is coming up",
            date: hoursBefore,
            category: "VET_REMINDER"
        )
    }

    func scheduleVaccinationReminder(vaccination: Vaccination, pet: Pet) {
        guard let dueDate = vaccination.nextDueDate else { return }

        // 1 week before
        let weekBefore = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: dueDate)!
        scheduleOneTimeNotification(
            id: "vax-week-\(vaccination.id)",
            title: "💉 Vaccination Due Soon",
            body: "\(pet.name)'s \(vaccination.name) vaccination is due in one week",
            date: weekBefore,
            category: "VACCINATION_REMINDER"
        )

        // Day of
        scheduleOneTimeNotification(
            id: "vax-day-\(vaccination.id)",
            title: "💉 Vaccination Due Today",
            body: "\(pet.name)'s \(vaccination.name) vaccination is due today",
            date: dueDate,
            category: "VACCINATION_REMINDER"
        )
    }

    func scheduleReminder(_ reminder: Reminder, pet: Pet) {
        let content = UNMutableNotificationContent()
        content.title = "🔔 \(reminder.title)"
        content.body = "Reminder for \(pet.name)"
        content.sound = .default

        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: reminder.time)
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: reminder.date)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute

        let trigger: UNNotificationTrigger
        switch reminder.repeatInterval {
        case .none:
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        case .daily:
            let daily = DateComponents(hour: timeComponents.hour, minute: timeComponents.minute)
            trigger = UNCalendarNotificationTrigger(dateMatching: daily, repeats: true)
        case .weekly:
            var weekly = DateComponents(hour: timeComponents.hour, minute: timeComponents.minute)
            weekly.weekday = calendar.component(.weekday, from: reminder.date)
            trigger = UNCalendarNotificationTrigger(dateMatching: weekly, repeats: true)
        case .monthly:
            var monthly = DateComponents(hour: timeComponents.hour, minute: timeComponents.minute)
            monthly.day = calendar.component(.day, from: reminder.date)
            trigger = UNCalendarNotificationTrigger(dateMatching: monthly, repeats: true)
        case .yearly:
            var yearly = DateComponents(hour: timeComponents.hour, minute: timeComponents.minute)
            yearly.month = calendar.component(.month, from: reminder.date)
            yearly.day = calendar.component(.day, from: reminder.date)
            trigger = UNCalendarNotificationTrigger(dateMatching: yearly, repeats: true)
        }

        let request = UNNotificationRequest(
            identifier: "reminder-\(reminder.id)",
            content: content,
            trigger: trigger
        )
        UNUserNotificationCenter.current().add(request)
    }

    func cancelNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }

    func cancelAllForItem(prefix: String, id: UUID) {
        let identifiers = ["\(prefix)-\(id)", "\(prefix)-day-\(id)", "\(prefix)-hour-\(id)", "\(prefix)-week-\(id)"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    private func scheduleOneTimeNotification(id: String, title: String, body: String, date: Date, category: String) {
        guard date > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        content.categoryIdentifier = category

        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}
