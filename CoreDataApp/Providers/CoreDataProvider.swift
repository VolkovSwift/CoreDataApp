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
    func addOrganization(name: String) -> Organization
}

class CoreDataProvider: CoreDataProviderType {
    
    
    lazy var coreDataStack = CoreDataStack(modelName: "CoreDataApp")
    var fetchRequest: NSFetchRequest<Organization>?
    
    func getOrganizations() -> [Organization] {
        guard let model =
                coreDataStack.managedContext
                .persistentStoreCoordinator?.managedObjectModel,
              let fetchRequest = model
                .fetchRequestTemplate(forName: "OrganizationsFetch")
                as? NSFetchRequest<Organization> else {
                    return []
                }
        do {
            return try coreDataStack.managedContext.fetch(fetchRequest)
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return []
        }
    }
    
    func getOrganization(name: String) -> Organization? {
//        guard let model =
//                coreDataStack.managedContext
//                .persistentStoreCoordinator?.managedObjectModel,
////              let fetchRequest = model
//
//                .fetchRequestTemplate(forName: "OrganizationsFetch")
////                as? NSFetchRequest<Organization> else {
//                    return nil
//                }
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Organization")
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(Organization.name), name)
        do {
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            return results.first as! Organization
            
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return nil
        }
    }
    
    
    func addOrganization(name: String) -> Organization {
        let organization = Organization(context: coreDataStack.managedContext)
        organization.name = name
        coreDataStack.saveContext()
        return organization
    }
    
    func getEmployees(of organization: Organization) -> NSOrderedSet {
        return organization.employees  ?? []
    }
    
    
    func addEmployee(orgName: String, name: String) -> Employee? {
        let employee = Employee(context: coreDataStack.managedContext)
        employee.name = name
        
        guard let org = getOrganization(name: orgName) else { return nil }
        org.addToEmployees(employee)
        
        
//        organization.addToEmployees(employee)
        coreDataStack.saveContext()
        return employee
    }
}
