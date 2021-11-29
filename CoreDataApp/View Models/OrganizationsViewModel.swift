import Combine

final class OrganizationsViewModel {
    
    // MARK: - Input
    
    let fetchOrganizationsSubject = PassthroughSubject<Void, Never>()
    let addButtonTappedSubject = PassthroughSubject<String, Never>()

    // MARK: - Output
    
    private let updateTriggerSubject = PassthroughSubject<Void, Never>()
    
    var updateTriggerPublisher: AnyPublisher<Void, Never> {
        updateTriggerSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Private properties

    private let coreDataProvider: CoreDataProvider
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    init(coreDataProvider: CoreDataProvider = CoreDataProvider()) {
        self.coreDataProvider = coreDataProvider
        setUpBindings()
    }
    
    // MARK: - Internal methods
    
    func getNumberOfOrganizations() -> Int {
        coreDataProvider.numbersOfOrganizations
    }
    
    func getOrganization(at index:Int) -> Organization? {
        coreDataProvider.organizationObject(at: index)
    }
    
    // MARK: - Private methods
    
    private func setUpBindings() {
        bindFetchOrganizationsSubject()
        bindAddButtonTappedSubject()
    }
    
    private func bindFetchOrganizationsSubject() {
        fetchOrganizationsSubject
            .sink { [weak self] _ in
                self?.coreDataProvider.fetchOrganizations {
                    self?.updateTriggerSubject.send()
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindAddButtonTappedSubject() {
        addButtonTappedSubject
            .sink { [weak self] name in
                self?.coreDataProvider.addOrganization(name: name, {
                    self?.coreDataProvider.fetchOrganizations {
                        self?.updateTriggerSubject.send()
                    }
                })
            }
            .store(in: &cancellables)
    }
}
