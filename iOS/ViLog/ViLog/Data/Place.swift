import Foundation
import CoreLocation

public struct Place: Identifiable, Hashable {
    public var id: String
    public let lat: CLLocationDegrees
    public let lng: CLLocationDegrees
    public let visits: [VisitSnapshot]
    public let name: String
}
