import UIKit
import CoreData


class Storage {

    static let shared = Storage()

    static var persistentContainer: NSPersistentContainer {
        return Storage.shared.persistentContainer
    }

    static var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container: NSPersistentContainer

        var groupID: String = "group.fummicc1.vilog"
        var appName = "ViLog"
#if DEBUG
        groupID += "-debug"
        appName = "D_ViLog"
#endif


        let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: groupID
        )!
        let storeURL = containerURL.appendingPathComponent("\(appName).sqlite")
        let description = NSPersistentStoreDescription(url: storeURL)
        container = NSPersistentContainer(name: "ViLog")
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        let storeDescription = description

        container.persistentStoreDescriptions = [storeDescription]

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                return
            }
        })

        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true

        do {
            try container.viewContext.setQueryGenerationFrom(.current)
        } catch {
            print("Failed to pin viewContext to the current generation: \(error)")
        }
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()

            } catch {
                let nserror = error as NSError
                print("Saving error: \(nserror)")
            }
        }
    }

    func fetchAllMonitoringPlaces() -> [MonitorPlace] {
        guard let response = try? persistentContainer.viewContext.fetch(.init(entityName: "MonitorPlace")) as? [MonitorPlace] else {
            return []
        }
        return response
    }
}
