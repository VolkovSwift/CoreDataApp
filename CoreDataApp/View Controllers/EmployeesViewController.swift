import UIKit
import Combine

final class EmployeesViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private var viewModel: EmployeesViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle

    init(viewModel: EmployeesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()
        setUpTableView()
        setUpBindings()
        viewModel.employeesFetchRequestSubject.send()
    }
    
    // MARK: - Private functions
    
    private func setUpLayout() {
        setUpNavigationBarLayout()
        setUpTableViewLayout()
    }
    
    private func setUpNavigationBarLayout() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
    }
    
    private func setUpTableViewLayout() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func setUpBindings() {
        reactToAddButtonTapped()
    }
    
    private func reactToAddButtonTapped() {
        viewModel.updateTriggerPublisher
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    
    @objc func addTapped(_ sender: UIBarButtonItem) {
        presentTextFieldAlert(title: "Add Employee", textFieldPlaceholder: "Enter Employee name") { [weak self] name in
            guard let self = self,
            let name = name else { return }
            
            self.viewModel.addButtonTappedSubject.send(name)
        }
    }
}

//MARK: - UITableViewDataSource & UITableViewDelegate
extension EmployeesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getNumberOfEmployees()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let employee = viewModel.getEmployee(at: indexPath.row)
        cell.textLabel?.text = employee?.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let employee = viewModel.getEmployee(at: indexPath.row)
        let viewModel = EmployeesViewModel(organizationID: viewModel.organizationID, bossID: employee?.objectID)
        let vc = EmployeesViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}
