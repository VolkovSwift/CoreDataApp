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


    let organizationID: NSManagedObjectID
    let bossID: NSManagedObjectID?
    private(set) var employees: NSOrderedSet?

    private let updateTriggerSubject = PassthroughSubject<Void, Never>()

    var updateTriggerPublisher: AnyPublisher<Void, Never> {
        updateTriggerSubject.eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization

    init(organizationID: NSManagedObjectID, bossID: NSManagedObjectID? = nil) {
        self.organizationID = organizationID
        self.bossID = bossID
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
                
                self.coreDataProvider.fetchEmployees(for: self.organizationID, bossID: self.bossID, {
                    self.updateTriggerSubject.send()
                })
            }
            .store(in: &cancellables)
    }
    
    private func reactToAddButtonTap() {
        addButtonTappedSubject
            .sink { [weak self] name in
                guard let self = self else { return }
                
                self.coreDataProvider.addEmployee(organizationID: self.organizationID, bossID: self.bossID, employeeName: name) {
                    self.updateTriggerSubject.send()
                }
            }
            .store(in: &cancellables)
    }
    
}
