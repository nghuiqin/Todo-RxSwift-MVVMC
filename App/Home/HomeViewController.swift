//
//  HomeViewController.swift
//  RxSwift-Todo
//
//  Created by Ng Hui Qin on 5/19/19.
//  Copyright © 2019 huiqinlab. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class HomeViewController: UIViewController {

    // MARK: Private

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: "Cell")
        return tableView
    }()

    private lazy var addBarItem: UIBarButtonItem = {
        let addItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
        return addItem
    }()

    private let viewModel: HomeViewModel
    private let bag: DisposeBag

    // MARK: Lifecycle

    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        self.bag = DisposeBag()
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupBinds()
    }

    private func setupViews() {
        // Set title
        title = "RxSwift"

        // Add Todo tableview
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        // Add navigation item
        navigationItem.rightBarButtonItem = addBarItem
    }

    private func setupBinds() {
        viewModel.outputs.todoItems
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(cellIdentifier: "Cell")) { _, model, cell in
                cell.textLabel?.text = model
            }
            .disposed(by: bag)

        addBarItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAddTodoAlert()
            })
            .disposed(by: bag)

        tableView.rx.setDelegate(self)
            .disposed(by: bag)
    }

    // MARK: Alerts
    private func showAddTodoAlert() {
        let alertController = UIAlertController(title: "Add Todo", message: "Insert your todo name", preferredStyle: .alert)

        let okAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard
                let textField = alertController.textFields?.first,
                let todoName = textField.text
            else { return }
            self?.viewModel.inputs.addTodoAction.onNext(todoName)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)

        alertController.addTextField { textField in
            textField.placeholder = "Todo name"
        }
        present(alertController, animated: true, completion: nil)
    }
}

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}
