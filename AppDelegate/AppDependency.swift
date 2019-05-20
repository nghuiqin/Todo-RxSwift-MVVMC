//
//  AppDependency.swift
//  RxSwift-Todo
//
//  Created by Hui Qin Ng on 2019/5/20.
//  Copyright © 2019 huiqinlab. All rights reserved.
//

import Foundation

struct AppDependency {
    let taskManager = TaskManager()
}

protocol CoordinatorDependency: class {
    var dependency: AppDependency? { set get }
}
