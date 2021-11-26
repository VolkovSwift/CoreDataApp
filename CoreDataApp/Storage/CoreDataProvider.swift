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
    lazy var coreDataStack = CoreDataStack(modelName: "CoreDataApp")
    
    
    
    
    private var organizationFetchedIDs: [NSManagedObjectID] = []
    private var employeesFetchedIDs: [NSManagedObjectID] = []
    private var filteredEmployeesFetchedIDs: [NSManagedObjectID] = []
    private var organizationObjects: [NSManagedObjectID: Organization] = [:]
    
    private var employeeObjects: [NSManagedObjectID: Employee] = [:]
    
    
    var numbersOfOrganizations: Int { organizationFetchedIDs.count }
    var numberOfEmployees: Int { filteredEmployeesFetchedIDs.count }
    
    
    func fetchOrganizations(_ completion: @escaping () -> Void) {
        coreDataStack.storeContainer.performBackgroundTask { [weak self] context in
            context.perform {
                let request: NSFetchRequest<NSManagedObjectID> = NSFetchRequest(entityName: "Organization")
                request.resultType = .managedObjectIDResultType
                
                self?.organizationFetchedIDs = (try? context.fetch(request)) ?? []
                completion()
            }
        }
    }
    
    func fetchEmployees(for organizationID: NSManagedObjectID, bossID: NSManagedObjectID?, _ completion: @escaping () -> Void) {
        coreDataStack.storeContainer.performBackgroundTask { [weak self] context in
            context.perform {
                self?.filteredEmployeesFetchedIDs.removeAll()
                
                if let bossID = bossID {
                    let request: NSFetchRequest<NSManagedObjectID> = NSFetchRequest(entityName: "Employee")
                    let boss = context.object(with: bossID)
                    request.predicate = NSPredicate(format: "boss = %@", boss)
                    
                    request.resultType = .managedObjectIDResultType
                    
                    self?.filteredEmployeesFetchedIDs = (try? context.fetch(request)) ?? []
                } else {
                    let request: NSFetchRequest<NSManagedObjectID> = NSFetchRequest(entityName: "Employee")
                    let org = context.object(with: organizationID)
                    request.predicate = NSPredicate(format: "organization = %@", org)
                    
                    request.resultType = .managedObjectIDResultType
                    
                    self?.filteredEmployeesFetchedIDs = (try? context.fetch(request)) ?? []
                }
                
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
        let id = filteredEmployeesFetchedIDs[index]
        
        if let object = employeeObjects[id] {
            return object
        }
        
        let viewContext = coreDataStack.storeContainer.viewContext
        if let object = try? viewContext.existingObject(with: id) as? Employee {
            employeeObjects[id] = object
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
                self.organizationFetchedIDs.append(organization.objectID)
                completion()
                
            } catch {
                print("error: \(error)")
                context.rollback()
            }
            completion()
        }
    }
    
    func addEmployee(organizationID: NSManagedObjectID, bossID: NSManagedObjectID?, employeeName: String, _ completion: @escaping () -> Void) {
        coreDataStack.storeContainer.performBackgroundTask { [self] context in
            let employee = Employee(context: context)
            employee.name = employeeName
            
           
            if let bossID = bossID,
               let boss = try? context.existingObject(with: bossID) as? Employee {
                employee.boss = boss
            }
            
            if let object = try? context.existingObject(with: organizationID) as? Organization {
               object.addToEmployees(employee)
            }
            
            do {
                try context.save()
                try? self.coreDataStack.storeContainer.viewContext.setQueryGenerationFrom(.current)
                context.automaticallyMergesChangesFromParent = true
                self.coreDataStack.storeContainer.viewContext.refreshAllObjects()
                self.employeesFetchedIDs.append(employee.objectID)
                completion()
            } catch {
                print("error: \(error)")
                context.rollback()
            }
        }
    }
}
