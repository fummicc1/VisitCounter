//
//  ViLogApp.swift
//  ViLog
//
//  Created by Fumiya Tanaka on 2022/05/22.
//

import SwiftUI
import Combine
import PartialSheet

@main
struct ViLogApp: App {
    let persistenceController = PersistenceController.shared

    @UIApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            RootView(
                locationManager: appDelegate.locationManager,
                placeManager: appDelegate.placeManager
            )
            .attachPartialSheetToRoot()
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let persistenceController = PersistenceController.shared
    let placeManager: PlaceManager = PlaceManagerImpl(persistenceController: .shared)
    let locationManager: LocationManager = LocationManagerImpl.shared
    private var cancellable: AnyCancellable?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        cancellable = locationManager.onEnterRegion.sink { region in
            do {
                let places: [MonitorPlace] = try self.persistenceController.container.viewContext.fetch(
                    .init(entityName: "MonitorPlace")
                )
                guard let place = places.first(where: { region.identifier == String(describing: $0.id) }) else {
                    // TODO: Notify as execption
                    return
                }
                let visiting = VisitSnapshot(context: self.persistenceController.container.viewContext)
                visiting.monitorPlace = place
                visiting.visitedAt = Date()
                try self.persistenceController.container.viewContext.save()
            } catch {
                // TODO: Handle error
                print(error)
            }
        }
        return true
    }
}
