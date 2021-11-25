//
//  EmployeesViewModel.swift
//  CoreDataApp
//
//  Created by Vlad Volkov on 21.11.21.
//

import Foundation
import Combine
import CoreData

final class EmployeesViewModel {
    
    // MARK: - Input
    let startSubject = PassthroughSubject<Void, Never>()
    let updateOrganizationsSubject = PassthroughSubject<Void, Never>()
    let addButtonTappedSubject = PassthroughSubject<String, Never>()

    // MARK: - Output
    let coreDataProvider: CoreDataProvider = CoreDataProvider()

    private(set) var organization: Organization
//    private(set) var employees: [Employee] = []
    
    let bossID: NSManagedObjectID
    private(set) var employees: NSOrderedSet?
    private(set) var boss: Employee?

    private let updateTriggerSubject = PassthroughSubject<Void, Never>()

    var updateTriggerPublisher: AnyPublisher<Void, Never> {
        updateTriggerSubject.eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization

    init(organization: Organization, id: NSManagedObjectID, boss: Employee? = nil) {
        self.organization = organization
        self.bossID = id
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
                
                self.coreDataProvider.fetchEmployees(for: self.organization.name ?? "") {
                    self.updateTriggerSubject.send()
                }
            }
            .store(in: &cancellables)
    }
    
    private func reactToAddButtonTap() {
        addButtonTappedSubject
        .sink { [weak self] name in
            guard let self = self else { return }
            
            self.coreDataProvider.generateEmployee(id: self.bossID, employeeName: name, bossName: self.organization.name ?? "") {
                self.updateTriggerSubject.send()
            }
        }
        .store(in: &cancellables)
    }
    
}
