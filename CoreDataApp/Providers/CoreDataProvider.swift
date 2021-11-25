//
//  CoreDataProvider.swift
//  CoreDataApp
//
//  Created by Vlad Volkov on 21.11.21.
//
import Foundation
import CoreData


protocol CoreDataProviderType {
    func getOrganizations() -> [Organization]
    func addOrganization(name: String) -> Organization?
}

class CoreDataProvider {
    
    private var organizationFetchedIDs: [NSManagedObjectID] = []
    private var employeesFetchedIDs: [NSManagedObjectID] = []
    private var organizationObjects: [NSManagedObjectID: Organization] = [:]
    private var employeesObjects: [NSManagedObjectID: Employee] = [:]
    
    
    var numbersOfOrganizations: Int { organizationFetchedIDs.count }
    var numberOfEmployees: Int { employeesFetchedIDs.count }
    
    
    func fetch(_ completion: @escaping () -> Void) {
        coreDataStack.storeContainer.performBackgroundTask { [weak self] context in
            context.perform {
                let request: NSFetchRequest<NSManagedObjectID> = NSFetchRequest(entityName: "Organization")
                request.resultType = .managedObjectIDResultType
                
                self?.organizationFetchedIDs = (try? context.fetch(request)) ?? []
                completion()
            }
        }
    }
    
    func fetchEmployees(for id: String, _ completion: @escaping () -> Void) {
        coreDataStack.storeContainer.performBackgroundTask { [weak self] context in
            context.perform {
                let request: NSFetchRequest<NSManagedObjectID> = NSFetchRequest(entityName: "Employee")
//                request.predicate = NSPredicate(format: "%K == %@", #keyPath(Employee.organization.objectID), id)
                
                request.resultType = .managedObjectIDResultType
                
                self?.employeesFetchedIDs = (try? context.fetch(request)) ?? []
                completion()
            }
        }
    }
    
    func object(at index: Int) -> Organization? {
        let id = organizationFetchedIDs[index]
        
        if let object = organizationObjects[id] {
            return object
        }
        
        let viewContext = coreDataStack.storeContainer.viewContext
        if let object = try? viewContext.existingObject(with: id) as? Organization {
            organizationObjects[id] = object
        }
        
        return nil
    }
    
    func employeeObject(at index: Int) -> Employee? {
        let id = employeesFetchedIDs[index]
        
        if let object = employeesObjects[id] {
            return object
        }
        
        let viewContext = coreDataStack.storeContainer.viewContext
        if let object = try? viewContext.existingObject(with: id) as? Employee {
            employeesObjects[id] = object
        }
        
        return nil
    }
    
    
    func generateOrganization(name: String, _ completion: @escaping () -> Void) {
        coreDataStack.storeContainer.performBackgroundTask { context in
            let organization = Organization(context: context)
            organization.name = name
            
            do {
                try context.save()
                try? self.coreDataStack.storeContainer.viewContext.setQueryGenerationFrom(.current)
                context.automaticallyMergesChangesFromParent = true
                self.coreDataStack.storeContainer.viewContext.refreshAllObjects()
                print("Add Item")
                self.organizationFetchedIDs.append(organization.objectID)
                completion()
                
            } catch {
                print("error: \(error)")
                context.rollback()
            }
        }
    }
    
    func generateEmployee(id: NSManagedObjectID, employeeName: String, bossName: String, _ completion: @escaping () -> Void) {
        coreDataStack.storeContainer.performBackgroundTask { [self] context in
            let employee = Employee(context: context)
            employee.name = employeeName
            
            
            let viewContext = self.coreDataStack.storeContainer.viewContext
            if let object = try? viewContext.existingObject(with: id) as? Organization {
                employee.organization = object
//                self.organizationObjects[id] = object
            }

            
            do {
                try context.save()
                try? self.coreDataStack.storeContainer.viewContext.setQueryGenerationFrom(.current)
                context.automaticallyMergesChangesFromParent = true
                self.coreDataStack.storeContainer.viewContext.refreshAllObjects()
                print("Add Item")
                self.employeesFetchedIDs.append(employee.objectID)
                completion()
                
            } catch {
                print("error: \(error)")
                context.rollback()
            }
        }
    }
    
    
    lazy var coreDataStack = CoreDataStack(modelName: "CoreDataApp")
    var fetchRequest: NSFetchRequest<Organization>?

}
