//
//  VisitingCountManager.swift
//  ViLog
//
//  Created by Fumiya Tanaka on 2022/06/02.
//

import Combine
import Foundation
import CoreLocation
import CoreData


class VisitingCountManagerImpl {

    private let locationManager: LocationManager
    private let persistenceController: PersistenceController
    private var cancellables: Set<AnyCancellable> = []

    public init(
        locationManager: LocationManager,
        persistenceController: PersistenceController
    ) {
        self.locationManager = locationManager
        self.persistenceController = persistenceController

        locationManager.onEnterRegion.sink { region in
            let coordinate = region.center
            let request = VisitSnapshot.fetchRequest()
            request.predicate = NSPredicate(
                format: "exitedAt = nil AND monitorPlace.latitude = %f AND monitorPlace.longitude = %f",
                coordinate.latitude, coordinate.longitude
            )
            let context = persistenceController.container.viewContext
            let visitings = (try? context.fetch(request)) ?? []
            if let alreadyVisiting = visitings.first {
                // TODO: send log that duplicated geo-fence was detected.
                print(alreadyVisiting)
            } else {
                let new = VisitSnapshot(context: context)
                let placeRequest = MonitorPlace.fetchRequest()
                placeRequest.predicate = NSPredicate(
                    format: "latitude = %f AND longitude = %f",
                    coordinate.latitude,
                    coordinate.longitude
                )
                do {
                    let places = try context.fetch(placeRequest)
                    guard let place = places.first else {
                        return
                    }
                    new.visitedAt = Date()
                    new.monitorPlace = place
                    try context.save()
                } catch {
                    print(error)
                }
            }
        }.store(in: &cancellables)

        locationManager.onExitRegion.sink { region in
            let coordinate = region.center
            let request = VisitSnapshot.fetchRequest()
            request.predicate = NSPredicate(
                format: "exitedAt = nil AND monitorPlace.latitude = %f AND monitorPlace.longitude = %f",
                coordinate.latitude, coordinate.longitude
            )
            let context = persistenceController.container.viewContext
            let snapshots = (try? context.fetch(request)) ?? []
            if let snapshot = snapshots.first {
                snapshot.exitedAt = Date()
                do {
                    try context.save()
                } catch {
                    print(error)
                }
            }
        }.store(in: &cancellables)
    }
}
