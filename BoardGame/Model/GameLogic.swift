typealias GameResult = (finished: Bool, winner: Player?)
protocol GameLogic {
    associatedtype P
    func getInitialBoard() -> Board<P>
    func getMoves(onBoard board: Board<P>, forPlayer: Player, forSourceCoords: Coords) -> [Move<P>]
    func getMoves(onBoard board: Board<P>, forPlayer player: Player) -> [Move<P>]
    func evaluateBoard(_ board: Board<P>) -> Double
    func getResult(onBoard board: Board<P>, forPlayer: Player) -> GameResult
}
