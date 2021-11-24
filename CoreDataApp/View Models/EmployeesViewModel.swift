//
//  EmployeesViewModel.swift
//  CoreDataApp
//
//  Created by Vlad Volkov on 21.11.21.
//

import Foundation
import Combine

final class EmployeesViewModel {
    
    // MARK: - Input
    let startSubject = PassthroughSubject<Void, Never>()
    let updateOrganizationsSubject = PassthroughSubject<Void, Never>()
    let addButtonTappedSubject = PassthroughSubject<String, Never>()

    // MARK: - Output
    let coreDataProvider: CoreDataProvider = CoreDataProvider()

    private(set) var organization: Organization
//    private(set) var employees: [Employee] = []
    private(set) var employees: NSOrderedSet?
    private(set) var boss: Employee?

    private let updateTriggerSubject = PassthroughSubject<Void, Never>()

    var updateTriggerPublisher: AnyPublisher<Void, Never> {
        updateTriggerSubject.eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization

    init(organization: Organization, boss: Employee? = nil) {
        self.organization = organization
        self.boss = boss
        self.setUpBindings()
    }

    
    private func setUpBindings() {
        bindTextFieldSubject()
        reactToAddButtonTap()
    }
    
    private func bindTextFieldSubject() {
        startSubject
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                if let boss = self.boss {
                    let fetchedEmployees = self.coreDataProvider.getEmployees(of: boss)
                    self.employees = fetchedEmployees
                } else {
                    let fetchedEmployees = self.coreDataProvider.getEmployees(of: self.organization)
                    self.employees = fetchedEmployees
                }
                self.updateTriggerSubject.send()
            }
            .store(in: &cancellables)
    }
    
    private func reactToAddButtonTap() {
        addButtonTappedSubject
        .sink { [weak self] name in
            guard let self = self else { return }
            if let boss = self.boss {
                let employee = self.coreDataProvider.addEmployeeWithBoss(bossName: boss.name ?? "", name: name)
//
//                self.employees.append(employee!)
                
                let mutable = self.employees?.mutableCopy() as! NSMutableOrderedSet
                mutable.add(employee)
                self.employees = mutable
            } else {
                let employee = self.coreDataProvider.addEmployee(orgName: self.organization.name ?? "", name: name)
//                self.employees.append(employee!)
//
                
                let mutable = self.employees?.mutableCopy() as! NSMutableOrderedSet
                mutable.add(employee)
                self.employees = mutable
            }
            
//            let mutable = self.employees?.mutableCopy() as! NSMutableOrderedSet
//            mutable.add(employee)
//            self.employees = mutable
            self.updateTriggerSubject.send()
        }
        .store(in: &cancellables)
    }
    
}
