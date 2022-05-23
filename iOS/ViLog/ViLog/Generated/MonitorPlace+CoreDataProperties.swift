//
//  MonitorPlace+CoreDataProperties.swift
//  ViLog
//
//  Created by Fumiya Tanaka on 2022/05/23.
//
//

import Foundation
import CoreData


extension MonitorPlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MonitorPlace> {
        return NSFetchRequest<MonitorPlace>(entityName: "MonitorPlace")
    }

    @NSManaged public var detail: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?

    public var id: String {
        "\(String(format: "%.5f", latitude)),\(String(format: "%.5f", latitude))"
    }
}

extension MonitorPlace : Identifiable {

}
