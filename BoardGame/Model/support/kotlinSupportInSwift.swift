//
//  kotlinSupportInSwift.swift
//  BoardGame
//
//  Created by Dominik Schultes on 03.07.20.
//  Copyright © 2020 THM. All rights reserved.
//

import Foundation

public extension Array {
    func copy() -> Array {
        return self
    }
}

public extension Double {
    var absoluteValue: Double {
        return abs(self)
    }
}

public extension Int {
    var absoluteValue: Int {
        return abs(self)
    }
}

func *(lhs: Int, rhs: Double) -> Double {
    return Double(lhs) * rhs
}

func -(lhs: Double, rhs: Int) -> Double {
    return lhs - Double(rhs)
}

// Concurrency
extension Array {
    func asyncMap<R>(transform: @escaping (Element) -> R, processResult: @escaping ([R]) -> ()) {
        let queue = DispatchQueue(label: "SequalsKconcurrency", attributes: .concurrent)
        let group = DispatchGroup()
        var result = [R?](repeating: nil, count: self.count)
        
        for i in 0..<self.count {
            let index = i // it is crucial to make this copy of the index
            queue.async(group: group) {
                result[index] = transform(self[index])
            }
        }
        
        group.notify(queue: .main) {
            processResult(result.map {$0!})
        }
    }
}
