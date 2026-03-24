import Foundation
import SwiftData
import SwiftUI

enum ActivitySection: String, CaseIterable, Identifiable {
    case walks, feeding, all
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .walks: return "Walks"
        case .feeding: return "Feeding"
        case .all: return "All Activity"
        }
    }
}

@Observable
final class ActivityViewModel {
    var selectedSection: ActivitySection = .walks
    var isWalkActive = false
    var showingAddFeeding = false
    var showingAddActivity = false

    let locationService = LocationService.shared

    func startWalk() {
        locationService.requestPermission()
        locationService.startTracking()
        isWalkActive = true
        HapticManager.impact(.heavy)
    }

    func stopWalk() -> (distance: Double, duration: TimeInterval) {
        let result = locationService.stopTracking()
        isWalkActive = false
        HapticManager.notification(.success)
        return (distance: result.distance * 0.000621371, duration: result.duration)
    }

    func todaysFeedingLogs(for pet: Pet) -> [FeedingLog] {
        pet.feedingLogs
            .filter { Calendar.current.isDateInToday($0.date) }
            .sorted { $0.time < $1.time }
    }

    func todaysCalories(for pet: Pet) -> Int {
        todaysFeedingLogs(for: pet)
            .compactMap { $0.calories }
            .reduce(0, +)
    }

    func recentWalks(for pet: Pet) -> [PetActivity] {
        pet.activities
            .filter { $0.type == .walk }
            .sorted { $0.date > $1.date }
    }

    func thisWeekWalkStats(for pet: Pet) -> (totalDistance: Double, totalDuration: TimeInterval, count: Int) {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let walks = pet.activities.filter { $0.type == .walk && $0.date >= startOfWeek }
        let totalDistance = walks.compactMap { $0.distance }.reduce(0, +)
        let totalDuration = walks.reduce(0) { $0 + $1.duration }
        return (totalDistance: totalDistance, totalDuration: totalDuration, count: walks.count)
    }

    func allActivities(for pet: Pet) -> [PetActivity] {
        pet.activities.sorted { $0.date > $1.date }
    }
}
