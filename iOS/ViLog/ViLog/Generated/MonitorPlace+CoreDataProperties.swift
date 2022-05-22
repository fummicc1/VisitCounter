//
//  MonitorPlace+CoreDataProperties.swift
//  ViLog
//
//  Created by Fumiya Tanaka on 2022/05/22.
//
//

import Foundation
import CoreData


extension MonitorPlace {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MonitorPlace> {
        return NSFetchRequest<MonitorPlace>(entityName: "MonitorPlace")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var detail: String?

}

extension MonitorPlace : Identifiable {

}
