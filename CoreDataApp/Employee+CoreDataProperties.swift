//
//  Employee+CoreDataProperties.swift
//  CoreDataApp
//
//  Created by Uladzislau Volkau on 25.11.21.
//
//

import Foundation
import CoreData


extension Employee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
        return NSFetchRequest<Employee>(entityName: "Employee")
    }

    @NSManaged public var name: String?
    @NSManaged public var boss: Employee?
    @NSManaged public var employees: NSOrderedSet?
    @NSManaged public var organization: Organization?

}

// MARK: Generated accessors for employees
extension Employee {

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

extension Employee : Identifiable {

}
