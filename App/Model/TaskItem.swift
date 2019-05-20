//
//  TaskItem.swift
//  RxSwift-Todo
//
//  Created by Hui Qin Ng on 2019/5/20.
//  Copyright © 2019 huiqinlab. All rights reserved.
//

import Foundation

struct TaskItem: Codable {
    let title: String
    var checked: Bool
    let createdAt: Date
}
