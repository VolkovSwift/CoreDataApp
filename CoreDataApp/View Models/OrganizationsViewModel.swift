//
//  OrganizationsViewModel.swift
//  CoreDataApp
//
//  Created by Vlad Volkov on 21.11.21.
//

import UIKit
import Combine

final class OrganizationsViewModel {
    
    // MARK: - Input
    let startSubject = PassthroughSubject<Void, Never>()
    let updateOrganizationsSubject = PassthroughSubject<Void, Never>()
    let addButtonTappedSubject = PassthroughSubject<String, Never>()

    // MARK: - Output
    let coreDataProvider: CoreDataProvider = CoreDataProvider()

    private(set) var organizations: [Organization] = []

    private let updateTriggerSubject = PassthroughSubject<Void, Never>()

    var updateTriggerPublisher: AnyPublisher<Void, Never> {
        updateTriggerSubject.eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init() {
        setUpBindings()
    }
    
    private func setUpBindings() {
        bindTextFieldSubject()
        reactToAddButtonTap()
    }
    
    private func bindTextFieldSubject() {
        startSubject
            .sink { [weak self] _ in
                self?.organizations = self?.coreDataProvider.getOrganizations() ?? []
                self?.updateTriggerSubject.send()
            }
            .store(in: &cancellables)
    }
    
    private func reactToAddButtonTap() {
        addButtonTappedSubject
        .sink { [weak self] name in
            guard let organization = self?.coreDataProvider.addOrganization(name: name) else { return }
//            self?.coreDataProvider.addOrganization(name: name)
            self?.organizations.append(organization)
            self?.updateTriggerSubject.send()
        }
        .store(in: &cancellables)
    }
    
}
