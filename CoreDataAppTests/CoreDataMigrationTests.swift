import XCTest
import CoreData
@testable import CoreDataApp

class CoreDataMigrationTests: XCTestCase {
    
    private var url: URL { return self.getDocumentsDirectory().appendingPathComponent("CoreDataAppTestURL.sqlite") }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }

    private func clearData() {
        try? FileManager.default.removeItem(at: url)
    }

    override func tearDown() {
        self.clearData()
    }
    
    func testMigrationFromV1toV2() {
        let oldModelURL = Bundle(for: AppDelegate.self).url(forResource: "CoreDataApp.momd/CoreDataApp", withExtension: "mom")!
        let oldManagedObjectModel = NSManagedObjectModel(contentsOf: oldModelURL)
        XCTAssertNotNil(oldManagedObjectModel)
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: oldManagedObjectModel!)
        
        try! coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        let organization = NSEntityDescription.insertNewObject(forEntityName: "Organization", into: managedObjectContext)
        organization.setValue("organization name", forKey: "name")
        
        try! managedObjectContext.save()
        
        let newModelURL = Bundle(for: AppDelegate.self).url(forResource: "CoreDataApp.momd/CoreDataApp v2", withExtension: "mom")!
        let newManagedObjectModel = NSManagedObjectModel(contentsOf: newModelURL)
        
        let options = [NSMigratePersistentStoresAutomaticallyOption: true, NSInferMappingModelAutomaticallyOption: true]
        
        let newCoordinator = NSPersistentStoreCoordinator(managedObjectModel: newManagedObjectModel!)
        try! newCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: options)
        let newManagedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        newManagedObjectContext.persistentStoreCoordinator = newCoordinator
        
        // test the migration
        let newOrganizationRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Organization")
        let newOrganizations = try! newManagedObjectContext.fetch(newOrganizationRequest) as! [NSManagedObject]
        XCTAssertEqual(newOrganizations.count, 1)
        XCTAssertEqual(newOrganizations.first?.value(forKey: "name") as? String, "organization name")
        XCTAssertEqual(newOrganizations.first?.value(forKey: "creationDate") as? Date, nil)
    }
}
