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
    var addTodoAction: PublishSubject<String> { get }
}

protocol HomeViewModelOutput {
    var todoItems: Observable<[String]> { get }
}

protocol HomeViewModelType {
    var inputs: HomeViewModelInput { get }
    var outputs: HomeViewModelOutput { get }
}

struct HomeViewModel: HomeViewModelType, HomeViewModelInput, HomeViewModelOutput {

    var inputs: HomeViewModelInput { return self }
    var outputs: HomeViewModelOutput { return self }

    // MARK: Inputs
    let addTodoAction = PublishSubject<String>()

    // MARK: Outputs
    var todoItems: Observable<[String]> {
        return items.asObservable()
    }

    // MARK: Private
    private let items = BehaviorRelay<[String]>(value: [])
    private let bag = DisposeBag()

    init() {
        bindAddAction()
    }

    private func bindAddAction() {
        addTodoAction
            .subscribe(onNext: { todoName in
                self.items.accept(self.items.value + [todoName])
            })
            .disposed(by: bag)
    }
}
