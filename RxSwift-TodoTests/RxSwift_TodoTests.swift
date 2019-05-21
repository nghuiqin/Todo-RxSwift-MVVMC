//
//  RxSwift_TodoTests.swift
//  RxSwift-TodoTests
//
//  Created by Ng Hui Qin on 5/19/19.
//  Copyright © 2019 huiqinlab. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
@testable import RxSwift_Todo

class RxSwift_TodoTests: XCTestCase {

    class DummyTaskManager: TaskManagerSyncActions {
        private var items = [TaskItem]()
        func retrieveTaskItems(completionHandler handler: @escaping (([TaskItem]?, Error?) -> Void)) {
            DispatchQueue.main.async {
                handler(self.items, nil)
            }
        }

        func synchronized(_ tasks: [TaskItem], completionHandler handler: @escaping ((Error?) -> Void)) {
            DispatchQueue.main.async {
                handler(nil)
            }
        }
    }

    private let bag = DisposeBag()
    private(set) var dummyManager: DummyTaskManager!
    private(set) var viewModel: HomeViewModel!

    override func setUp() {
        dummyManager = DummyTaskManager()
        viewModel = HomeViewModel(taskManager: dummyManager)
    }

    func test001_InitialState() {
        let exp = expectation(description: "Get empty task list")
        viewModel.outputs.todoItems
            .subscribe(onNext: { items in
                if items.isEmpty {
                    exp.fulfill()
                }
            })
            .disposed(by: bag)

        viewModel.inputs.refreshTrigger.onNext(())
        wait(for: [exp], timeout: 5)
    }

    func test002_AddTask() {
        let exp = expectation(description: "Add a task")
        let testTitle = "Hello, world"
        viewModel.outputs.todoItems
            .subscribe(onNext: { items in
                guard
                    let firstItem = items.first,
                    firstItem.title == testTitle,
                    firstItem.checked == false
                else { return }
                exp.fulfill()
            })
            .disposed(by: bag)

        viewModel.inputs.addTodoAction.onNext(testTitle)
        wait(for: [exp], timeout: 5)
    }

    func test003_ToggleTask() {
        let exp = expectation(description: "Toggle a task")

        viewModel.outputs.todoItems
            .subscribe(onNext: { items in
                guard
                    let firstItem = items.first,
                    firstItem.checked == true
                    else { return }
                exp.fulfill()
            })
            .disposed(by: bag)

        viewModel.inputs.addTodoAction.onNext("Try")
        viewModel.inputs.toggleTodoAction.onNext(0)
        wait(for: [exp], timeout: 5)
    }
}
