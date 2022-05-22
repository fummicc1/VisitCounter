import Foundation
import CoreLocation
import SwiftUI
import UserNotifications

class MonitorPlaceModel: ObservableObject {

    @Published var alreadyNotifiable: Bool = false
    @Published var storedMonitoringPlace: MonitorPlace?
    @Published var error: String? = nil

    func willResignNotification() {
        guard let storedMonitoringPlace = storedMonitoringPlace else {
            return
        }
        let id = String(describing: storedMonitoringPlace.id)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        alreadyNotifiable = false
    }

    func didRegisterNotification() async {
        guard let isAuthorized = try? await UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]
            ),
              isAuthorized else {
            return
        }

        guard let storedMonitoringPlace = storedMonitoringPlace else {
            return
        }
        let id = String(describing: storedMonitoringPlace)
        let content = UNMutableNotificationContent()
        content.title = "\(storedMonitoringPlace.name)が近くにあります"
        content.body = "アプリを開いて確認しましょう"
        let trigger = UNLocationNotificationTrigger(
            region: CLCircularRegion(
                center: CLLocationCoordinate2D(
                    latitude: storedMonitoringPlace.latitude,
                    longitude: storedMonitoringPlace.longitude
                ),
                radius: 15,
                identifier: id
            ),
            repeats: true
        )
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger
        )
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            self.error = error.localizedDescription
        }
    }
}
