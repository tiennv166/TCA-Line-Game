//
//  BallColor.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import GameplayKit

enum BallColor: Int, Codable {
    case color1 = 0
    case color2
    case color3
    case color4
    case color5
    case color6
    case color7

    var imageNamed: String {
        switch self {
        case .color1: return "ball_red"
        case .color2: return "ball_blue"
        case .color3: return "ball_green"
        case .color4: return "ball_gold"
        case .color5: return "ball_cyan"
        case .color6: return "ball_yellow"
        case .color7: return "ball_purple"
        }
    }

    static var random: BallColor {
        let randomDistribution = GKRandomDistribution(
            lowestValue: BallColor.color1.rawValue,
            highestValue: BallColor.color7.rawValue
        )
        let random = randomDistribution.nextInt()
        return BallColor(rawValue: random) ?? .color1
    }
}
