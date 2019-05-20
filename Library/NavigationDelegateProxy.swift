//
//  CoordinatorNavigationDelegateProxy.swift
//  CoodinatorPractice
//
//  Created by GreenChiu on 2019/2/15.
//  Copyright © 2019 Green. All rights reserved.
//

import UIKit

class NavigationDelegateProxy: NSObject, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        guard
            let previousViewController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(previousViewController) else {
                return
        }
        viewController.coordinator?.stopChildren()
    }
}
