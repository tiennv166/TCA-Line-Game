//
//  GameStorable.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import Foundation

struct GameStorable: Equatable, Codable {
    var score: Int = 0
    var board: Board = Board.random
}
