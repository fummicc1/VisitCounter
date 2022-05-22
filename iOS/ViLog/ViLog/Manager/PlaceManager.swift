import Foundation
import Combine
import MapKit
import CoreData

public protocol PlaceManager {
    var placesPublisher: AnyPublisher<[Place], Never> { get }
    var places: [Place] { get }

    func getVisits(place: MonitorPlace) -> [VisitSnapshot]
}

public class PlaceManagerImpl: NSObject, PlaceManager {
    private let placesSubject: CurrentValueSubject<[Place], Never> = .init([])

    private let persistenceController: PersistenceController

    public init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        super.init()
    }


    public var places: [Place] {
        placesSubject.value
    }

    public var placesPublisher: AnyPublisher<[Place], Never> {
        placesSubject.eraseToAnyPublisher()
    }

    public func getVisits(place: MonitorPlace) -> [VisitSnapshot] {
        let request = NSFetchRequest<VisitSnapshot>(entityName: "VisitSnapshot")
        do {
            let visits = try persistenceController.container.viewContext.fetch(request)
            return visits
        } catch {
            print(error)
        }
        return []
    }
}

extension PlaceManagerImpl {
}
