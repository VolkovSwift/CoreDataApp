//
//  ViewController.swift
//  CoreDataApp
//
//  Created by Vlad Volkov on 19.11.21.
//

import UIKit

class OrganizationsViewController: UIViewController {
    
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
        return viewModel.organizations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        let organization = viewModel.organizations[indexPath.row]
        cell.textLabel?.text = organization
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let _ = viewModel.organizations[indexPath.row]
        print("Hello")
    }
    
    @objc func addTapped() {
        print("Add")
    }
    
    
}

