import Foundation

typealias ᏫBool = Bool

postfix operator ☯++
postfix operator ☯--
prefix operator ☯++
prefix operator ☯--

public extension Int {
    @discardableResult static postfix func ☯++(x: inout Int) -> Int {
        defer {x += 1}
        return x
    }

    @discardableResult static postfix func ☯--(x: inout Int) -> Int {
        defer {x -= 1}
        return x
    }

    @discardableResult static prefix func ☯++(x: inout Int) -> Int {
        x += 1
        return x
    }

    @discardableResult static prefix func ☯--(x: inout Int) -> Int {
        x -= 1
        return x
    }
}

public extension Array {
    func copy() -> Array {
        return self
    }

    func isNotEmpty() -> Bool {
        return !self.isEmpty
    }
}

public extension Sequence {
    func zip<Sequence2>(_ other: Sequence2) -> Zip2Sequence<Self, Sequence2> {
        return Swift.zip(self, other)
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