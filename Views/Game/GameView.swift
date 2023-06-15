//
//  GameView.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture
import SwiftUI
import SpriteKit

struct GameView: View {
    
    let store: StoreOf<Root>

    private var scene: GameScene {
        let scene = GameScene(size: CGSize(width: 300, height: 300), store: store)
        scene.scaleMode = .aspectFit
        return scene
    }
        
    var body: some View {
        SpriteView(scene: scene, options: .ignoresSiblingOrder)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(store: StoreOf<Root>(initialState: Root.State()) { Root() })
    }
}
