//
//  VisitSnapshot+CoreDataProperties.swift
//  ViLog
//
//  Created by Fumiya Tanaka on 2022/06/02.
//
//

import Foundation
import CoreData


extension VisitSnapshot {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<VisitSnapshot> {
        return NSFetchRequest<VisitSnapshot>(entityName: "VisitSnapshot")
    }

    @NSManaged public var visitedAt: Date?
    @NSManaged public var exitedAt: Date?
    @NSManaged public var monitorPlace: MonitorPlace?

}

extension VisitSnapshot : Identifiable {

}
