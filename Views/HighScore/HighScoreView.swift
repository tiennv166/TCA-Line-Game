//
//  HighScoreView.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture
import SwiftUI

struct HighScoreView: View {
    
    let store: StoreOf<HighScore>
    
    struct ScoreIdentifiable: Identifiable {
        let index: Int
        let score: Score
        var id: Int { index }
    }
    
    var body: some View {
        WithViewStore(store) { viewStore in
            List(
                viewStore.scores
                    .sorted { $0.score > $1.score }
                    .enumerated()
                    .map(ScoreIdentifiable.init)
            ) { element in
                HStack {
                    Text("\(element.index + 1). \(element.score.playerName)")
                        .font(
                            .system(size: 16)
                            .weight(.bold)
                        )
                    Spacer()
                    Text("\(element.score.score)")
                        .font(
                            .system(size: 20)
                        )
                }
            }
        }
        .onAppear { ViewStore(store).send(.loadHighScores) }
    }
}

struct HighScoreView_Previews: PreviewProvider {
    static var previews: some View {
        HighScoreView(store: StoreOf<HighScore>(initialState: HighScore.State()) { HighScore() })
    }
}
