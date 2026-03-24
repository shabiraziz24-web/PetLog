import Foundation
import CoreLocation
import MapKit

@Observable
final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()

    var isTracking = false
    var currentLocation: CLLocation?
    var routeLocations: [CLLocation] = []
    var totalDistance: Double = 0
    var elapsedTime: TimeInterval = 0
    var authorizationStatus: CLAuthorizationStatus = .notDetermined

    private let locationManager = CLLocationManager()
    private var startTime: Date?
    private var timer: Timer?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.activityType = .fitness
        locationManager.distanceFilter = 5
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        routeLocations = []
        totalDistance = 0
        elapsedTime = 0
        startTime = Date()
        isTracking = true

        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(start)
        }
    }

    func stopTracking() -> (distance: Double, duration: TimeInterval, route: [CLLocation]) {
        isTracking = false
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil

        let result = (distance: totalDistance, duration: elapsedTime, route: routeLocations)
        return result
    }

    func pauseTracking() {
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
    }

    func resumeTracking() {
        locationManager.startUpdatingLocation()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self, let start = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(start)
        }
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        for location in locations {
            guard location.horizontalAccuracy < 20 else { continue }
            if let lastLocation = routeLocations.last {
                totalDistance += location.distance(from: lastLocation)
            }
            routeLocations.append(location)
            currentLocation = location
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    // MARK: - Helpers

    var distanceInMiles: Double {
        totalDistance * 0.000621371
    }

    var distanceInKm: Double {
        totalDistance / 1000
    }

    var elapsedTimeFormatted: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, remainingMinutes, seconds)
        }
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func encodeRoute() -> String? {
        guard !routeLocations.isEmpty else { return nil }
        let coords = routeLocations.map { "\($0.coordinate.latitude),\($0.coordinate.longitude)" }
        return coords.joined(separator: ";")
    }
}
