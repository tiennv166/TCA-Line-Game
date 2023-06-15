//
//  BallColor+Extension.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import UIKit

extension BallColor {
    var toUiColor: UIColor {
        switch self {
        case .color1: return UIColor.red
        case .color2: return UIColor(red: 70.0 / 255.0, green: 110.0 / 255.0, blue: 250.0 / 255.0, alpha: 1)
        case .color3: return UIColor(red: 99.0 / 255.0, green: 252.0 / 255.0, blue: 67.0 / 255.0, alpha: 1)
        case .color4: return UIColor(red: 137.0 / 255.0, green: 106.0 / 255.0, blue: 55.0 / 255.0, alpha: 1)
        case .color5: return UIColor(red: 41.0 / 255.0, green: 183.0 / 255.0, blue: 202.0 / 255.0, alpha: 1)
        case .color6: return UIColor.yellow
        case .color7: return UIColor(red: 177.0 / 255.0, green: 47.0 / 255.0, blue: 250.0 / 255.0, alpha: 1)
        }
    }
}
