import Foundation
import CoreData

protocol CoreDataProviderType {
    func fetchOrganizations(_ completion: @escaping () -> Void)
    func fetchEmployees(for organizationID: NSManagedObjectID, bossID: NSManagedObjectID?, _ completion: @escaping () -> Void)
    func addOrganization(name: String, _ completion: @escaping () -> Void)
    func addEmployee(organizationID: NSManagedObjectID, bossID: NSManagedObjectID?, employeeName: String, _ completion: @escaping () -> Void)
    func organizationObject(at index: Int) -> Organization?
    func employeeObject(at index: Int) -> Employee?
}

class CoreDataProvider {
    
    // MARK: - Internal properties
    
    var numbersOfOrganizations: Int { organizationFetchedIDs.count }
    var numberOfEmployees: Int { employeesFetchedIDs.count }
    
    // MARK: - Private properties
    
    private let coreDataStack: CoreDataStack
    
    private var organizationFetchedIDs: [NSManagedObjectID] = []
    private var employeesFetchedIDs: [NSManagedObjectID] = []
    
    private var organizationObjects: [NSManagedObjectID: Organization] = [:]
    private var employeeObjects: [NSManagedObjectID: Employee] = [:]
    
    // MARK: - Init
    
    public init(coreDataStack: CoreDataStack = CoreDataStack()) {
      self.coreDataStack = coreDataStack
    }
    
    // MARK: - Internal methods
    
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
    
    func fetchEmployees(with organizationID: NSManagedObjectID, bossID: NSManagedObjectID?, _ completion: @escaping () -> Void) {
        coreDataStack.storeContainer.performBackgroundTask { [weak self] context in
            context.perform {
                guard let self = self else { return }
                self.employeesFetchedIDs.removeAll()
                
                if let bossID = bossID {
                    self.perforFetchRequestWithExistingBoss(bossID: bossID, context: context)
                } else {
                    self.perforFetchRequestWithoutExistingBoss(organizationID: organizationID, context: context)
                }
                completion()
            }
        }
    }
    
    func addOrganization(name: String, _ completion: @escaping () -> Void) {
        coreDataStack.storeContainer.performBackgroundTask { [weak self] context in
            guard let self = self else { return }
            let organization = Organization(context: context)
            organization.name = name
            
            do {
                try context.save()
                self.synchronizeContext(backgroundcontext: context)
                self.addOrganization(organization)
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
            
            assignBossToEmployee(employee: employee,
                                 bossID: bossID,
                                 context: context)
            
            
            assignOrganizationToEmployee(employee: employee,
                                         organizationID: organizationID,
                                         context: context)
            do {
                try context.save()
                synchronizeContext(backgroundcontext: context)
                addEmployee(employee)
            } catch {
                print("error: \(error)")
                context.rollback()
            }
            completion()
        }
    }
    
    func organizationObject(at index: Int) -> Organization? {
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
        
        if let object = employeeObjects[id] {
            return object
        }
        
        let viewContext = coreDataStack.storeContainer.viewContext
        if let object = try? viewContext.existingObject(with: id) as? Employee {
            employeeObjects[id] = object
        }
        
        return nil
    }
    
    // MARK: - Private methods
    
    private func perforFetchRequestWithExistingBoss(bossID: NSManagedObjectID, context: NSManagedObjectContext) {
        let request: NSFetchRequest<NSManagedObjectID> = NSFetchRequest(entityName: "Employee")
        let boss = context.object(with: bossID)
        request.predicate = NSPredicate(format: "boss = %@", boss)
        
        request.resultType = .managedObjectIDResultType
        
        employeesFetchedIDs = (try? context.fetch(request)) ?? []
    }
    
    private func perforFetchRequestWithoutExistingBoss(organizationID: NSManagedObjectID, context: NSManagedObjectContext) {
        let request: NSFetchRequest<NSManagedObjectID> = NSFetchRequest(entityName: "Employee")
        let org = context.object(with: organizationID)
        let organizationPredicate = NSPredicate(format: "organization = %@", org)
        let bossPredicate = NSPredicate(format: "boss == nil")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [organizationPredicate, bossPredicate])
        
        request.resultType = .managedObjectIDResultType
        
        employeesFetchedIDs = (try? context.fetch(request)) ?? []
    }
    
    
    private func assignBossToEmployee(employee: Employee, bossID: NSManagedObjectID?, context: NSManagedObjectContext) {
        if let bossID = bossID,
           let boss = try? context.existingObject(with: bossID) as? Employee {
            employee.boss = boss
        }
    }
    
    private func assignOrganizationToEmployee(employee: Employee, organizationID: NSManagedObjectID, context: NSManagedObjectContext) {
        if let object = try? context.existingObject(with: organizationID) as? Organization {
           object.addToEmployees(employee)
        }
    }
    
    private func synchronizeContext(backgroundcontext: NSManagedObjectContext) {
        let mainViewContext = coreDataStack.storeContainer.viewContext
        try? mainViewContext.setQueryGenerationFrom(.current)
        backgroundcontext.automaticallyMergesChangesFromParent = true
        mainViewContext.refreshAllObjects()
    }
    
    private func addEmployee(_ employee: Employee) {
        self.employeesFetchedIDs.append(employee.objectID)
        
        if let object = try? coreDataStack.storeContainer.viewContext.existingObject(with: employee.objectID) as? Employee {
            employeeObjects[employee.objectID] = object
        }
    }
    
    private func addOrganization(_ organization: Organization) {
        organizationFetchedIDs.append(organization.objectID)
        
        if let object = try? coreDataStack.storeContainer.viewContext.existingObject(with: organization.objectID) as? Organization {
            organizationObjects[organization.objectID] = object
        }
    }
}
