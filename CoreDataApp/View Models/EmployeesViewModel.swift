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
    private(set) var employees: NSOrderedSet?
//    private(set) var boss: Employee?

    private let updateTriggerSubject = PassthroughSubject<Void, Never>()

    var updateTriggerPublisher: AnyPublisher<Void, Never> {
        updateTriggerSubject.eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization

    init(organization: Organization) {
        self.organization = organization
//        super.init()
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
                self.employees = self.coreDataProvider.getEmployees(of: self.organization)
                self.updateTriggerSubject.send()
            }
            .store(in: &cancellables)
    }
    
    private func reactToAddButtonTap() {
        addButtonTappedSubject
        .sink { [weak self] name in
            guard let self = self else { return }
                  
//            let organization = self.coreDataProvider.addOrganization(name: name) else { return }
                  
//            let organization = self
            let employee = self.coreDataProvider.addEmployee(orgName: self.organization.name ?? "", name: name)
//            let employee = self.coreDataProvider.addEmployee(organization: self.organization, name: name)
//            let mutable = self.employees?.mutableCopy() as! NSMutableOrderedSet
//            organization.addToEmployees(employee)
//            mutable.add(employee)
//            self.employees = mutable
            self.updateTriggerSubject.send()
        }
        .store(in: &cancellables)
    }
    
}
