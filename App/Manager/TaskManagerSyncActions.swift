//
//  TaskManagerSyncActions.swift
//  RxSwift-Todo
//
//  Created by Hui Qin Ng on 2019/5/20.
//  Copyright © 2019 huiqinlab. All rights reserved.
//

import Foundation

protocol TaskManagerSyncActions: class {
    func retrieveTaskItems(completionHandler handler: @escaping (([TaskItem]?, Error?) -> Void))
    func synchronized(_ tasks: [TaskItem], completionHandler handler: @escaping ((Error?) -> Void))
}
