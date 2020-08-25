#if false
let Ꮻpackage = "de.thm.mow.boardgame.model"
let Ꮻimports = ["de.thm.mow.boardgame.model.support.*"]
#endif

typealias GameResult = (finished: Bool, winner: Player?)
protocol GameLogic {
    associatedtype P
    func getInitialBoard() -> Board<P>
    func getMoves(onBoard board: Board<P>, forPlayer: Player, forSourceCoords: Coords) -> [Move<P>]
    func getMoves(onBoard board: Board<P>, forPlayer player: Player) -> [Move<P>]
    func evaluateBoard(_ board: Board<P>, forPlayer player: Player) -> Double
    func getResult(onBoard board: Board<P>, forPlayer: Player) -> GameResult
}
