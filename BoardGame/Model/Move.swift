typealias Coords = (x: Int, y: Int)
typealias Effect<P> = (coords: Coords, newPiece: P)
typealias Step<P> = (target: Coords, effects: [Effect<P>])
struct Move<P> {
    let source: Coords
    let steps: [Step<P>]
    var value: Double?
}
