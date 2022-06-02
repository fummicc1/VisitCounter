import CoreData

public struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<10 {
            let place = MonitorPlace(context: viewContext)
            place.longitude = 139.839478
            place.latitude = 35.652832
            place.name = "Test_\(i)"
        }
        do {
            try viewContext.save()
        } catch {            
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ViLog")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            let groupID: String = Const.groupID
            let appName = Const.appName

            let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: groupID
            )!
            let storeURL = containerURL.appendingPathComponent("\(appName).sqlite")
            container.persistentStoreDescriptions.first!.url = storeURL
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
