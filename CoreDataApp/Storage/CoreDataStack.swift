import Foundation
import CoreData

class CoreDataStack {
    lazy var managedContext: NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    init() {
        try? storeContainer.viewContext.setQueryGenerationFrom(.current)
    }
    
    lazy var storeContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDataApp")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                print("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext () {
        guard managedContext.hasChanges else { return }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Unresolved error \(error), \(error.userInfo)")
        }
    }
}
