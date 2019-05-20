//
//  TaskManager.swift
//  RxSwift-Todo
//
//  Created by Hui Qin Ng on 2019/5/20.
//  Copyright © 2019 huiqinlab. All rights reserved.
//

import Foundation

class TaskManager: TaskManagerSyncActions {

    private let dispatchQueue = DispatchQueue(label: "todo.data.manager", qos: .default, attributes: .concurrent)
    private let filepath: String = {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first! + "/todos.txt"
    }()

    func retrieveTaskItems(completionHandler handler: @escaping (([TaskItem]?, Error?) -> Void)) {
        dispatchQueue.async { [unowned self] in
            var results: [TaskItem]?
            var catchError: Error?

            defer {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3, execute: {
                    handler(results, catchError)
                })
            }

            guard FileManager.default.fileExists(atPath: self.filepath) else { return }

            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: self.filepath, isDirectory: false))
                let decoder = JSONDecoder()
                let list = try decoder.decode([TaskItem].self, from: data)
                results = list
            }
            catch {
                catchError = error
            }
        }
    }

    func synchronized(_ tasks: [TaskItem], completionHandler handler: @escaping ((Error?) -> Void)) {
        dispatchQueue.asyncAfter(deadline: .now() + 3) { [unowned self] in
            do {
                let data = try JSONEncoder().encode(tasks)
                try data.write(to: URL(fileURLWithPath: self.filepath), options: .atomic)
                DispatchQueue.main.async {
                    handler(nil)
                }
            }
            catch {
                DispatchQueue.main.async {
                    handler(error)
                }
            }
        }
    }
}
