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
                self?.employees = self?.coreDataProvider.getEmployees(of: self!.organization) ?? []
                self?.updateTriggerSubject.send()
            }
            .store(in: &cancellables)
    }
    
    private func reactToAddButtonTap() {
        addButtonTappedSubject
        .sink { [weak self] name in
            guard let organization = self?.coreDataProvider.addOrganization(name: name) else { return }
            self?.coreDataProvider.addEmployee(organization: organization, name: name)
            self?.updateTriggerSubject.send()
        }
        .store(in: &cancellables)
    }
    
}
