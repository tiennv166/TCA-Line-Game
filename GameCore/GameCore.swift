//
//  GameCore.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import GameplayKit

extension Board {
    static let minimumBallsInLine = 5

    static func getScore(numOfBalls: Int) -> Int {
        guard numOfBalls >= minimumBallsInLine else { return 0 }
        if numOfBalls == minimumBallsInLine { return 5 }
        return Int(5 + pow(2.0, Double(numOfBalls - minimumBallsInLine) + 1))
    }
    
    static func generateRandomBalls(_ numberOfBalls: Int, excepts: [Ball] = []) -> [Ball] {
        let numberOfCells = Board.dimensions * Board.dimensions
        let possibleCells = Array(Set(0..<numberOfCells).subtracting(Set(excepts.map(\.cellIndex))))
        let numberOfResult = min(numberOfBalls, possibleCells.count)
        let randomDistribution = GKShuffledDistribution(
            lowestValue: 0,
            highestValue: possibleCells.count - 1
        )
        return Array(0..<numberOfResult).map { _ in
            let random = possibleCells[randomDistribution.nextInt()]
            return Ball(
                xPos: Int32(random % Board.dimensions),
                yPos: Int32(random / Board.dimensions),
                color: BallColor.random
            )
        }
    }
    
    static var random: Board {
        let balls = Board.generateRandomBalls(4)
        let nextBalls = Board.generateRandomBalls(3, excepts: balls)
        return Board(balls: balls, nextBalls: nextBalls)
    }
    
    static func getScoringBalls(around ball: Ball, in balls: [Ball]) -> [Ball] {
        var result: [Ball] = []
        // Prepare
        var temp: [Ball]
        var x: Int32
        var y: Int32

        /// Get balls in vertical line
        temp = [ball]
        // Top
        y = ball.yPos + 1
        while y < Int32(Board.dimensions) {
            let gridPos = GridPosition(ball.xPos, y)
            guard let ballIdx = balls.first(where: { $0.gridPosition == gridPos }) else { break }
            guard ball.color == ballIdx.color else { break }
            temp.append(ballIdx)
            y += 1
        }
        // Bottom
        y = ball.yPos - 1
        while y >= 0 {
            let gridPos = GridPosition(ball.xPos, y)
            guard let ballIdx = balls.first(where: { $0.gridPosition == gridPos }) else { break }
            guard ball.color == ballIdx.color else { break }
            temp.append(ballIdx)
            y -= 1
        }
        if temp.count >= Board.minimumBallsInLine {
            result += temp
        }

        /// Get balls in horizontal line
        temp = [ball]
        // Top
        x = ball.xPos + 1
        while x < Int32(Board.dimensions) {
            let gridPos = GridPosition(x, ball.yPos)
            guard let ballIdx = balls.first(where: { $0.gridPosition == gridPos }) else { break }
            guard ball.color == ballIdx.color else { break }
            temp.append(ballIdx)
            x += 1
        }
        // Bottom
        x = ball.xPos - 1
        while x >= 0 {
            let gridPos = GridPosition(x, ball.yPos)
            guard let ballIdx = balls.first(where: { $0.gridPosition == gridPos }) else { break }
            guard ball.color == ballIdx.color else { break }
            temp.append(ballIdx)
            x -= 1
        }
        if temp.count >= Board.minimumBallsInLine {
            result += temp
        }

        /// Diagonal line 1
        temp = [ball]
        // Top
        x = ball.xPos + 1
        y = ball.yPos + 1
        while x < Int32(Board.dimensions) && y < Int32(Board.dimensions) {
            let gridPos = GridPosition(x, y)
            guard let ballIdx = balls.first(where: { $0.gridPosition == gridPos }) else { break }
            guard ball.color == ballIdx.color else { break }
            temp.append(ballIdx)
            y += 1
            x += 1
        }
        // Bottom
        x = ball.xPos - 1
        y = ball.yPos - 1
        while x >= 0 && y >= 0 {
            let gridPos = GridPosition(x, y)
            guard let ballIdx = balls.first(where: { $0.gridPosition == gridPos }) else { break }
            guard ball.color == ballIdx.color else { break }
            temp.append(ballIdx)
            y -= 1
            x -= 1
        }
        if temp.count >= Board.minimumBallsInLine {
            result += temp
        }

        /// Diagonal line 2
        temp = [ball]
        // Top
        x = ball.xPos - 1
        y = ball.yPos + 1
        while x >= 0 && y < Int32(Board.dimensions) {
            let gridPos = GridPosition(x, y)
            guard let ballIdx = balls.first(where: { $0.gridPosition == gridPos }) else { break }
            guard ball.color == ballIdx.color else { break }
            temp.append(ballIdx)
            y += 1
            x -= 1
        }
        // Bottom
        x = ball.xPos + 1
        y = ball.yPos - 1
        while x < Int32(Board.dimensions) && y >= 0 {
            let gridPos = GridPosition(x, y)
            guard let ballIdx = balls.first(where: { $0.gridPosition == gridPos }) else { break }
            guard ball.color == ballIdx.color else { break }
            temp.append(ballIdx)
            y -= 1
            x += 1
        }
        if temp.count >= Board.minimumBallsInLine {
            result += temp
        }

        return result
    }
}
