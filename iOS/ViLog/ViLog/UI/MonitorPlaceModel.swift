import Foundation
import CoreLocation
import SwiftUI
import UserNotifications

class MonitorPlaceModel: ObservableObject {

    @Published var alreadyNotifiable: Bool = false
    @Published var place: Place
    @Published var error: String? = nil

    init(place: Place) {
        self.place = place
        Task {
            let requests = await UNUserNotificationCenter.current().pendingNotificationRequests()
            await MainActor.run(body: {
                self.alreadyNotifiable = requests.contains { request in
                    request.identifier == String(describing: place.id)
                }
            })
        }
    }

    func willResignNotification() {
        let id = String(describing: place.id)
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

        let id = String(describing: place.id)
        let content = UNMutableNotificationContent()
        content.title = "\(place.name)が近くにあります"
        content.body = "アプリを開いて確認しましょう"
        let trigger = UNLocationNotificationTrigger(
            region: CLCircularRegion(
                center: CLLocationCoordinate2D(
                    latitude: self.place.lat,
                    longitude: self.place.lng
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
            await MainActor.run(body: {
                self.alreadyNotifiable = true
            })
        } catch {
            self.error = error.localizedDescription
        }
    }
}
