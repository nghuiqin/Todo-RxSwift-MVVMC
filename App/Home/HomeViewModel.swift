//
//  HomeViewModel.swift
//  RxSwift-Todo
//
//  Created by Ng Hui Qin on 5/19/19.
//  Copyright © 2019 huiqinlab. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol HomeViewModelInput {
    var addTodoAction: PublishSubject<TaskItem> { get }
}

protocol HomeViewModelOutput {
    var todoItems: Observable<[TaskItem]> { get }
    var isLoading: Driver<Bool> { get }
}

protocol HomeViewModelType {
    var inputs: HomeViewModelInput { get }
    var outputs: HomeViewModelOutput { get }
}

struct HomeViewModel: HomeViewModelType, HomeViewModelInput, HomeViewModelOutput {

    // MARK: Private
    private unowned let taskManager: TaskManager
    private let items = BehaviorRelay<[TaskItem]>(value: [])
    private let loading = BehaviorRelay<Bool>(value: false)
    private let bag = DisposeBag()

    // MARK: Inputs
    let addTodoAction = PublishSubject<String>()
    let refreshTrigger = PublishSubject<Void>()

    // MARK: Outputs
    var todoItems: Observable<[TaskItem]> {
        return items.asObservable()
    }

    var isLoading: Driver<Bool> {
        return loading.asDriver(onErrorJustReturn: false)
    }

    var inputs: HomeViewModelInput { return self }
    var outputs: HomeViewModelOutput { return self }

    init(taskManager: TaskManager) {
        self.taskManager = taskManager
        let requestTasks = self.loading
            .sample(refreshTrigger)
            .flatMap { isLoading -> Observable<[TaskItem]> in
                if isLoading {
                    return Observable.empty()
                }
                return Observable.create({ subscriber in
                    taskManager.retrieveTaskItems(completionHandler: { items, error in
                        guard
                            let tasks = items,
                            error == nil
                        else { return }
                        subscriber.onNext(tasks)
                        subscriber.onCompleted()
                    })
                    return Disposables.create()
                })
            }
            .share()

        requestTasks
            .bind(to: items)
            .disposed(by: bag)

        BehaviorRelay.merge(
            requestTasks.map { _ in true },
            items.map { _ in false }
            )
            .bind(to: loading)
            .disposed(by: bag)

        bindAddAction()
    }

    private func bindAddAction() {
        self.inputs.addTodoAction
            .subscribe(onNext: { todoName in
                self.items.accept(self.items.value + [todoName])
            })
            .disposed(by: bag)
    }
}
