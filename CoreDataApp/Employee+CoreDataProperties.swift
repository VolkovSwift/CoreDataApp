//
//  Employee+CoreDataProperties.swift
//  CoreDataApp
//
//  Created by Uladzislau Volkau on 24.11.21.
//
//

import Foundation
import CoreData


extension Employee {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Employee> {
        return NSFetchRequest<Employee>(entityName: "Employee")
    }

    @NSManaged public var name: String?
    @NSManaged public var organization: Organization?

}

extension Employee : Identifiable {

}
