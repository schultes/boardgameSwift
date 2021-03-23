import Foundation

extension Array {
    func asyncMapOnlyOneThread<R>(transform: @escaping (Element) -> R, processResult: @escaping ([R]) -> ()) {
        DispatchQueue.global().async {
            var result = [R?](repeating: nil, count: self.count)
            for i in 0..<self.count {
                result[i] = transform(self[i])
            }
            DispatchQueue.main.async {
                processResult(result.map {$0!})
            }
        }
    }
}
