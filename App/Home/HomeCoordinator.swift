//
//  HomeCoordinator.swift
//  RxSwift-Todo
//
//  Created by Ng Hui Qin on 5/19/19.
//  Copyright © 2019 huiqinlab. All rights reserved.
//

import UIKit

class HomeCoordinator: Coordinator<UINavigationController> {

    private (set) var viewController: UIViewController!

    override func start() {
        if started {
            return
        }
        let viewModel = HomeViewModel()
        let vc = HomeViewController(viewModel: viewModel)
        viewController = vc
        show(viewController: viewController)
        super.start()
    }
}
