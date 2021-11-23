//
//  Organization+CoreDataProperties.swift
//  CoreDataApp
//
//  Created by Vlad Volkov on 23.11.21.
//
//

import Foundation
import CoreData


extension Organization {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Organization> {
        return NSFetchRequest<Organization>(entityName: "Organization")
    }

    @NSManaged public var name: String?
    @NSManaged public var employees: NSOrderedSet?

}

// MARK: Generated accessors for employees
extension Organization {

    @objc(insertObject:inEmployeesAtIndex:)
    @NSManaged public func insertIntoEmployees(_ value: Employee, at idx: Int)

    @objc(removeObjectFromEmployeesAtIndex:)
    @NSManaged public func removeFromEmployees(at idx: Int)

    @objc(insertEmployees:atIndexes:)
    @NSManaged public func insertIntoEmployees(_ values: [Employee], at indexes: NSIndexSet)

    @objc(removeEmployeesAtIndexes:)
    @NSManaged public func removeFromEmployees(at indexes: NSIndexSet)

    @objc(replaceObjectInEmployeesAtIndex:withObject:)
    @NSManaged public func replaceEmployees(at idx: Int, with value: Employee)

    @objc(replaceEmployeesAtIndexes:withEmployees:)
    @NSManaged public func replaceEmployees(at indexes: NSIndexSet, with values: [Employee])

    @objc(addEmployeesObject:)
    @NSManaged public func addToEmployees(_ value: Employee)

    @objc(removeEmployeesObject:)
    @NSManaged public func removeFromEmployees(_ value: Employee)

    @objc(addEmployees:)
    @NSManaged public func addToEmployees(_ values: NSOrderedSet)

    @objc(removeEmployees:)
    @NSManaged public func removeFromEmployees(_ values: NSOrderedSet)

}

extension Organization : Identifiable {

}
