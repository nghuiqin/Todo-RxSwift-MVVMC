//
//  Coordinator.swift
//  CoodinatorPractice
//
//  Created by GreenChiu on 2019/2/14.
//  Copyright © 2019 Green. All rights reserved.
//

import UIKit

class Coordinator<T: UIViewController> : Coordinating {
    private(set) var started: Bool = false
    lazy var identifier: String = {
        return String(describing: self) + "_\(arc4random() % 1000)"
    }()
    
    var childCoordinators = [Coordinating]()
    
    weak final var parent: Coordinating?
    
    let rootViewController: T
    
    required init(viewController: T) {
        rootViewController = viewController
    }
    
    func start() -> Void {
        // Do your action before call super.start()
        
        started = true
    }
    
    func stop() -> Void {
        // Do your action before call super.stop()
        
        started = false
        stopChildren()
    }
    
    final func startChild( coordinator : Coordinating ) {
        guard !childCoordinators.contains(where: {$0 === coordinator}) else {
            return
        }
        coordinator.parent = self
        childCoordinators.append(coordinator)
        coordinator.start()
    }
    
    final func stopChild( coordinator: Coordinating) {
        coordinator.stop()
        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
            childCoordinators.remove(at: index)
        }
    }
    
    final func stopChildren() {
        childCoordinators.forEach {
            $0.stop()
        }
        childCoordinators.removeAll()
    }
    
    func didReceiveDestoried( viewController: UIViewController) {
        parent?.stopChild(coordinator: self)
    }
    
    func active() {
        childCoordinators.forEach {
            $0.active()
        }
    }
    
    func deactive() {
        childCoordinators.forEach {
            $0.deactive()
        }
    }
    
    final func present( viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        viewController.coordinator = self
        rootViewController.present(viewController, animated: animated, completion: completion)
    }
}

extension Coordinator where T: UINavigationController {
    final func show( viewController: UIViewController, animated: Bool = true)  {
        viewController.coordinator = self
        rootViewController.pushViewController(viewController, animated: animated)
    }
    
    typealias ClusterPushableCoordinating = Coordinating & CoordinatingVisibleViewController
    final func push<Element: ClusterPushableCoordinating>( coordinators: [Element]) where T: UINavigationController {
        let newViewControllers = coordinators.map {
            $0.visibleViewController
        }
        var currentViewControllers = rootViewController.viewControllers
        currentViewControllers += newViewControllers
        rootViewController.setViewControllers(currentViewControllers, animated: true)
        
        
        var previousCoordinator: Element?
        coordinators.forEach {
            $0.start()
            
            if let previousCoordinator = previousCoordinator {
                $0.parent = previousCoordinator
            }
            else {
                $0.parent = self
            }
            
            if let parentCoordinator = $0.parent as? Coordinator {
                parentCoordinator.childCoordinators.append($0)
            }
            
            previousCoordinator = $0
        }
    }
    
    final var coordinatorsAtNavigationController: [Coordinating] {
        return rootViewController.viewControllers.compactMap {
            $0.coordinator
        }
    }
    
    final func pop(to coordinator: Coordinating) {
        guard let index = coordinatorsAtNavigationController.firstIndex(where: { coordinator === $0 }) else {
            return
        }
        let destinationVC = rootViewController.viewControllers[index]
        _ = rootViewController.popToViewController(destinationVC, animated: true)
    }
}

