import Foundation
import Combine
import MapKit
import CoreData

public protocol PlaceManager {
    var placesPublisher: AnyPublisher<[Place], Never> { get }
    var places: [Place] { get }

    func getVisits(place: MonitorPlace) -> [VisitSnapshot]
    func getVisits(place: Place) -> [VisitSnapshot]
}

public class PlaceManagerImpl: NSObject {
    private let placesSubject: CurrentValueSubject<[Place], Never> = .init([])

    private let persistenceController: PersistenceController

    public init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        super.init()
        guard let places = try? persistenceController.container.viewContext.fetch(
            MonitorPlace.fetchRequest()
        ) else {
            return
        }
        placesSubject.send(places.map({ monitor in
            Place(
                id: String(describing: monitor.id),
                lat: monitor.latitude,
                lng: monitor.longitude,
                visits: getVisits(place: monitor),
                name: monitor.name ?? ""
            )
        }))
    }
}

extension PlaceManagerImpl: PlaceManager {

    public var places: [Place] {
        placesSubject.value
    }

    public var placesPublisher: AnyPublisher<[Place], Never> {
        placesSubject.eraseToAnyPublisher()
    }

    public func getVisits(place: MonitorPlace) -> [VisitSnapshot] {
        let request = VisitSnapshot.fetchRequest()
        request.predicate = NSPredicate(format: "monitorPlace = %@", place)
        do {
            let visits = try persistenceController.container.viewContext.fetch(request)
            return visits
        } catch {
            print(error)
        }
        return []
    }

    public func getVisits(place: Place) -> [VisitSnapshot] {
        let request = VisitSnapshot.fetchRequest()
        request.predicate = NSPredicate(format: "monitorPlace.id = %@", place.id)
        do {
            let visits = try persistenceController.container.viewContext.fetch(request)
            return visits
        } catch {
            print(error)
        }
        return []
    }
}
