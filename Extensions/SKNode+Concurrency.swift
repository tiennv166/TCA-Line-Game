//
//  SKNode+Concurrency.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import SpriteKit

extension SKNode {
    func run(_ action: SKAction) async {
        await withCheckedContinuation { continuation in
            run(action) { continuation.resume(returning: ()) }
        }
    }
}

extension Dictionary where Key == SKNode, Value == SKAction {
    func runParallel() async {
        await withTaskGroup(of: Void.self) { group in
            keys.forEach { node in
                guard let action = self[node] else { return }
                group.addTask { await node.run(action) }
            }
        }
    }
}
