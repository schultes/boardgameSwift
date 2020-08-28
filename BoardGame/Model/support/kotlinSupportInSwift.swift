//
//  kotlinSupportInSwift.swift
//  BoardGame
//
//  Created by Dominik Schultes on 03.07.20.
//  Copyright © 2020 THM. All rights reserved.
//

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
