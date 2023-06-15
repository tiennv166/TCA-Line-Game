//
//  Board.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import GameplayKit

struct Board: Equatable, Codable {

    /**
     * Defines the width (and height) of the maze.
     * This is the actual number of rows (and columns) of the maze graph.
     */
    static let dimensions = 9
    
    let balls: [Ball]
    let nextBalls: [Ball]

    /**
     * Find the shortest path by using GameplayKit's pathfinding
     * on the board's GKGridGraph.
     */
    func findPath(from startPosition: GridPosition, to endPosition: GridPosition) -> [GridPosition] {
        // Make graph
        let graph = GKGridGraph(
            fromGridStartingAt: SIMD2<Int32>(0, 0),
            width: Int32(Board.dimensions),
            height: Int32(Board.dimensions),
            diagonalsAllowed: false
        )
        let ballNodes = balls
            .compactMap { graph.node(atGridPosition: $0.gridPosition) }
            .filter { $0.gridPosition != startPosition }
        graph.remove(ballNodes)
        // Find path
        guard let startNode = graph.node(atGridPosition: startPosition) else { return [] }
        guard let endNode = graph.node(atGridPosition: endPosition) else { return [] }
        guard let result = graph.findPath(from: startNode, to: endNode) as? [GKGridGraphNode] else { return [] }
        return result.map(\.gridPosition)
    }
    
    func ball(in position: GridPosition) -> Ball? {
        balls.first { $0.gridPosition == position }
    }
    
    var isGameOver: Bool {
        balls.count >= Board.dimensions * Board.dimensions
    }
}
