//
//  AppCoordinator.swift
//  RxSwift-Todo
//
//  Created by Ng Hui Qin on 5/19/19.
//  Copyright © 2019 huiqinlab. All rights reserved.
//

import UIKit

class AppCoordinator: Coordinator<UINavigationController> {

    private let delegateProxy: NavigationDelegateProxy

    required init(viewController: UINavigationController) {
        delegateProxy = NavigationDelegateProxy()
        viewController.interactivePopGestureRecognizer?.delegate = delegateProxy
        viewController.delegate = delegateProxy
        super.init(viewController: viewController)
    }

    override func start() {
        let rootViewCoordinator = HomeCoordinator(viewController: rootViewController)
//        rootViewCoordinator.appDependency = dependency
        startChild(coordinator: rootViewCoordinator)
        super.start()
    }
}
