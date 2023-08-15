//
//  ScoreView.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture
import SwiftUI

struct ScoreView: View {
    
    let store: StoreOf<Game>
    
    var body: some View {
        GeometryReader { geometry -> ZStack in
            ZStack {
                Image("sceneBg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    .shadow(radius: 10)
                WithViewStore(store, observe: { $0 }) { viewStore in
                    Text(String(format: "%06d", viewStore.score))
                        .font(
                            .system(size: 32)
                            .weight(.bold)
                        )
                }
            }
        }
    }
}

struct ScoreView_Previews: PreviewProvider {
    static var previews: some View {
        ScoreView(store: StoreOf<Game>(initialState: Game.State()) { Game() })
    }
}

