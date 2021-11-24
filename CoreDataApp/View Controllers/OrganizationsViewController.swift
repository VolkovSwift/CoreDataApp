import UIKit
import CoreData
import Combine

final class OrganizationsViewController: UIViewController {
    
    // MARK: - Private properties
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = .zero
        return tableView
    }()
    
    private var viewModel: OrganizationsViewModel = OrganizationsViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    
    
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
        navigationItem.title = "Organizations"
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
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Actions
    @objc func addTapped(_ sender: UIBarButtonItem) {
        let alert = Alert.errorAlert(title: "Add Organization") { name in
            self.viewModel.addButtonTappedSubject.send(name)
        }
        
        present(alert,animated: true)
    }
}

//MARK: - UITableViewDataSource & UITableViewDelegate
extension OrganizationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.organizations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let organization = viewModel.organizations[indexPath.row]
        cell.textLabel?.text = organization.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let organization = viewModel.organizations[indexPath.row]
        let viewModel = EmployeesViewModel(organization: organization)
        let vc = EmployeesViewController(viewModel: viewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
}




