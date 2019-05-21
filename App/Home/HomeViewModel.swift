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
import RxDataSources

protocol HomeViewModelInput {
    var addTodoAction: PublishSubject<String> { get }
    var refreshTrigger: PublishSubject<Void> { get }
    var toggleTodoAction: PublishSubject<Int> { get }
}

protocol HomeViewModelOutput {
    var todoItems: Observable<[TaskItem]> { get }
    var isLoading: Driver<Bool> { get }
    var hasError: Driver<String> { get }
}

protocol HomeViewModelType {
    var inputs: HomeViewModelInput { get }
    var outputs: HomeViewModelOutput { get }
}

class HomeViewModel: HomeViewModelType, HomeViewModelInput, HomeViewModelOutput {

    // MARK: Private
    private let items = BehaviorRelay<[TaskItem]>(value: [])
    private let loading = BehaviorRelay<Bool>(value: false)
    private let synchronized = BehaviorRelay<Bool>(value: false)
    private let errorSubject = PublishSubject<Error>()
    private let bag = DisposeBag()

    // MARK: Inputs
    let addTodoAction = PublishSubject<String>()
    let refreshTrigger = PublishSubject<Void>()
    let toggleTodoAction = PublishSubject<Int>()

    // MARK: Outputs
    var todoItems: Observable<[TaskItem]> {
        return items.asObservable()
    }

    var isLoading: Driver<Bool> {
        return loading.asDriver(onErrorJustReturn: false)
    }

    var hasError: Driver<String> {
        return errorSubject
            .map { $0.localizedDescription }
            .asDriver(onErrorJustReturn: "No Error description")
    }

    var inputs: HomeViewModelInput { return self }
    var outputs: HomeViewModelOutput { return self }

    init(taskManager: TaskManagerSyncActions) {
        let requestTasks = refreshTrigger
            .flatMapLatest { _ -> Observable<[TaskItem]> in
                return Observable.create({ subscriber in
                    taskManager.retrieveTaskItems(completionHandler: { items, error in
                        guard
                            let tasks = items,
                            error == nil
                        else {
                            subscriber.onError(error!)
                            subscriber.onCompleted()
                            return
                        }
                        subscriber.onNext(tasks)
                        subscriber.onCompleted()
                    })
                    return Disposables.create()
                })
            }
            .catchError({ [unowned self] error in
                self.errorSubject.onNext(error)
                return .empty()
            })
            .share()

        items
            .filter { !$0.isEmpty }
            .flatMapLatest { items -> Observable<Bool> in
                return Observable.create({ subscriber in
                    subscriber.onNext(false)
                    taskManager.synchronized(items, completionHandler: { error in
                        guard error == nil else {
                            subscriber.onError(error!)
                            subscriber.onCompleted()
                            return
                        }
                        subscriber.onNext(true)
                        subscriber.onCompleted()
                    })
                    return Disposables.create()
                })
            }
            .catchError({ [unowned self] error in
                self.errorSubject.onNext(error)
                return .empty()
            })
            .bind(to: synchronized)
            .disposed(by: bag)

        requestTasks
            .bind(to: items)
            .disposed(by: bag)

        BehaviorRelay.merge(
            requestTasks.map { _ in false },
            synchronized.map { _ in false },
            items.map { _ in true }.asObservable()
            )
            .bind(to: loading)
            .disposed(by: bag)

        bindTodoAction()
    }

    private func bindTodoAction() {
        addTodoAction
            .subscribe(onNext: { [unowned self] todoName in
                let task = TaskItem(
                    title: todoName,
                    checked: false,
                    createdAt: Date()
                )
                self.items.accept(self.items.value + [task])
            })
            .disposed(by: bag)

        toggleTodoAction
            .subscribe(onNext: { [unowned self] index in
                var currentItems = self.items.value
                guard index < currentItems.count else { return }
                var item = currentItems[index]
                item.checked = !item.checked
                currentItems[index] = item
                self.items.accept(currentItems)
            })
            .disposed(by: bag)
    }
}
