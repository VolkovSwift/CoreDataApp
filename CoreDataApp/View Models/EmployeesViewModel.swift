import Foundation
import Combine
import CoreData

final class EmployeesViewModel {
    
    // MARK: - Input
    
    let employeesFetchRequestSubject = PassthroughSubject<Void, Never>()
    let addButtonTappedSubject = PassthroughSubject<String, Never>()

    // MARK: - Output
    
    private let updateTriggerSubject = PassthroughSubject<Void, Never>()
    
    var updateTriggerPublisher: AnyPublisher<Void, Never> {
        updateTriggerSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Properties
    
    let organizationID: NSManagedObjectID

    // MARK: - Private properties

    private let coreDataProvider: CoreDataProvider
    private let bossID: NSManagedObjectID?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization

    init(coreDataProvider: CoreDataProvider = CoreDataProvider(),
         organizationID: NSManagedObjectID,
         bossID: NSManagedObjectID? = nil) {
        self.coreDataProvider = coreDataProvider
        self.organizationID = organizationID
        self.bossID = bossID
        self.setUpBindings()
    }
    
    // MARK: - Internal methods
    
    func getNumberOfEmployees() -> Int {
        coreDataProvider.numberOfEmployees
    }
    
    func getEmployee(at index:Int) -> Employee? {
        coreDataProvider.employeeObject(at: index)
    }
    
    // MARK: - Private methods

    private func setUpBindings() {
        bindFetchEmployeesSubject()
        bindAddButtonTappedSubject()
    }
    
    private func bindFetchEmployeesSubject() {
        employeesFetchRequestSubject
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.coreDataProvider.fetchEmployees(with: self.organizationID, bossID: self.bossID, {
                    self.updateTriggerSubject.send()
                })
            }
            .store(in: &cancellables)
    }
    
    private func bindAddButtonTappedSubject() {
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
