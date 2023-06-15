//
//  NextBallsView.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture
import SwiftUI

struct NextBallsView: View {
    
    let store: StoreOf<Game>
    
    struct ViewState: Equatable {
      var nextBalls: [Ball]

      init(state: Game.State) {
          self.nextBalls = state.board.nextBalls
      }
    }

    var body: some View {
        WithViewStore(store, observe: ViewState.init) { viewStore in
            GeometryReader { geometry -> ZStack in
                ZStack {
                    if !viewStore.nextBalls.isEmpty {
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
                    }
                    HStack(spacing: 8) {
                        ForEach(viewStore.nextBalls) { ball in
                            Image(ball.color.imageNamed)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 48, height: 48)
                        }
                    }
                }
            }
        }
    }
}

struct NextBallsView_Previews: PreviewProvider {
    static var previews: some View {
        NextBallsView(store: StoreOf<Game>(initialState: Game.State()) { Game() })
    }
}
