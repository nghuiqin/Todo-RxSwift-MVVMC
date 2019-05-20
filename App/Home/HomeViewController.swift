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

    private lazy var indicatorView: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        return indicator
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

        // loading navigation item
        let indicatorItem = UIBarButtonItem(customView: indicatorView)
        navigationItem.leftBarButtonItem = indicatorItem
    }

    private func setupBinds() {
        let outputs = viewModel.outputs
        let inputs = viewModel.inputs

        outputs.todoItems
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items(
                cellIdentifier: "Cell",
                cellType: HomeTableViewCell.self)) { _, task, cell in
                cell.setupContent(with: task)
            }
            .disposed(by: bag)

        outputs.isLoading
            .map { !$0 }
            .drive(addBarItem.rx.isEnabled)
            .disposed(by: bag)

        outputs.isLoading
            .drive(indicatorView.rx.isAnimating)
            .disposed(by: bag)

        outputs.hasError
            .drive(onNext: { [weak self] errorMessage in
                self?.showErrorAlert(errorMessage)

            })
            .disposed(by: bag)

        addBarItem.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showAddTodoAlert()
            })
            .disposed(by: bag)

        rx.sentMessage(#selector(viewWillAppear(_:)))
            .map { _ in () }
            .bind(to: inputs.refreshTrigger)
            .disposed(by: bag)

        tableView.rx.itemSelected
            .map { $0.row }
            .bind(to: inputs.toggleTodoAction)
            .disposed(by: bag)
    }

    // MARK: Alerts
    private func showErrorAlert(_ errorString: String) {
        let alertController = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)

        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)

        present(alertController, animated: true, completion: nil)
    }

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
