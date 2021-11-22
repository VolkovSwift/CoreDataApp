//
//  ViewController.swift
//  CoreDataApp
//
//  Created by Vlad Volkov on 19.11.21.
//

import UIKit
import CoreData

class OrganizationsViewController: UIViewController {
    
    var fetchRequest: NSFetchRequest<Organization>?
    
    lazy var coreDataStack = CoreDataStack(modelName: "CoreDataApp")
    
    var organizations: [Organization] = []
    
    private var viewModel: OrganizationsViewModel = OrganizationsViewModel()

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorInset = .zero
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpLayout()
        setUpTableView()
//        self.title = "Organizations"
        self.navigationItem.title = "Your Title"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
        view.backgroundColor = .red
        
        
        
        guard let model =
          coreDataStack.managedContext
            .persistentStoreCoordinator?.managedObjectModel,
          let fetchRequest = model
            .fetchRequestTemplate(forName: "OrganizationsFetch")
            as? NSFetchRequest<Organization> else {
              return
        }

        self.fetchRequest = fetchRequest
        fetchAndReload()
    }
    
    func fetchAndReload() {

        guard let fetchRequest = fetchRequest else {
          return
        }

        do {
          organizations =
            try coreDataStack.managedContext.fetch(fetchRequest)
          tableView.reloadData()
        } catch let error as NSError {
          print("Could not fetch \(error), \(error.userInfo)")
        }
      }

    private func setUpLayout() {
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
}

extension OrganizationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return organizations.count
//        return viewModel.organizations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
//        let organization = viewModel.organizations[indexPath.row]
        let organization = organizations[indexPath.row]
        cell.textLabel?.text = organization.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _ = viewModel.organizations[indexPath.row]
        print("Hello")
    }
    
    @objc func addTapped(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Organization",
                                        message: "Add a new name",
                                        preferredStyle: .alert)
//
          let saveAction = UIAlertAction(title: "Save",
                                         style: .default) {
//              print("HEY")
            [unowned self] action in
////
            guard let textField = alert.textFields?.first,
              let nameToSave = textField.text else {
                return
            }

              let organization = Organization(context: coreDataStack.managedContext)
              organization.name = nameToSave


//
            self.organizations.append(organization)
            coreDataStack.saveContext()
            self.tableView.reloadData()
          }
//
          let cancelAction = UIAlertAction(title: "Cancel",
                                           style: .cancel)
//
          alert.addTextField()
//
          alert.addAction(saveAction)
          alert.addAction(cancelAction)
//
          present(alert, animated: true)
//        tableView.reloadData()
    }
    }
    


