import UIKit
import Combine

final class EmployeesViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = .zero
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
        viewModel.startSubject.send()
    }
    
    // MARK: - Private functions
    
    private func setUpLayout() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        setUpTableViewLayout()
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
        let alert = Alert.errorAlert(title: "Add Employee") { name in
            self.viewModel.addButtonTappedSubject.send(name)
        }
        present(alert,animated: true)
    }
}

//MARK: - UITableViewDataSource & UITableViewDelegate
extension EmployeesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.coreDataProvider.numberOfEmployees
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let employee = viewModel.coreDataProvider.employeeObject(at: indexPath.row)
        cell.textLabel?.text = employee?.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let employee = viewModel.coreDataProvider.employeeObject(at: indexPath.row)
        let viewModel = EmployeesViewModel(organizationID: viewModel.organizationID, bossID: employee?.objectID)
        let vc = EmployeesViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
}
