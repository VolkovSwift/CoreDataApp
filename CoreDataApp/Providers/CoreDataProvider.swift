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
    
    func addOrganization(name: String) -> Organization {
        let organization = Organization(context: coreDataStack.managedContext)
        organization.name = name
        coreDataStack.saveContext()
        return organization
    }
}
