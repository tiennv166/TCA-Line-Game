//
//  RootView.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture
import SwiftUI

struct RootView: View {
    
    let store: StoreOf<Root>
    @State private var playerName = ""
    @State private var isHighScoresShowing = false
    @State private var isSettingsShowing = false
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
                .ignoresSafeArea()
                .frame(width: UIScreen.main.bounds.width)
            VStack(spacing: 0) {
                HStack(spacing: 10) {
                    ScoreView(store: store.scope(state: \.game, action: Root.Action.game))
                        .frame(width: 160, height: 48)
                    Spacer()
                    NextBallsView(store: store.scope(state: \.game, action: Root.Action.game))
                        .frame(width: 160, height: 48)
                }
                .padding(16)
                GameView(store: store)
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                    .background(Color.black)
                    .opacity(0.8)
                WithViewStore(store, observe: { $0 }) { viewStore in
                    HStack(spacing: 10) {
                        CustomButton(
                            action: { isHighScoresShowing.toggle() },
                            image: Image("leaderboards")
                        )
                        Spacer()
                        CustomButton(
                            action: { isSettingsShowing.toggle() },
                            image: Image("gear")
                        )
                        if viewStore.game.canUndo {
                            CustomButton(
                                action: { viewStore.send(.game(.undo)) },
                                image: Image("arrowLeft")
                            )
                        }
                        CustomButton(
                            action: { viewStore.send(.settings(.toggleSoundEnabaled)) },
                            image: viewStore.settings.isSoundEnabled ? Image("musicOff") : Image("musicOn")
                        )
                    }
                    .padding(16)
                    .alert(
                        "Score: \(viewStore.game.score)",
                        isPresented: viewStore.binding(get: \.game.isGameOver, send: .game(.createNewGame))
                    ) {
                        TextField("Player name", text: $playerName)
                            .textInputAutocapitalization(.never)
                        Button("New game", role: .cancel) {
                            let scrore = Score(playerName: playerName, score: viewStore.game.score)
                            viewStore.send(.highScore(.addScore(scrore)))
                        }
                    } message: {
                        Text("Please enter your name")
                    }
                }
            }
        }
        .sheet(isPresented: $isHighScoresShowing) {
            NavigationView {
                HighScoreView(store: store.scope(state: \.highScore, action: Root.Action.highScore))
                    .navigationBarItems(leading: Button("Close") { isHighScoresShowing.toggle() })
                    .navigationBarTitle("Leaderboard", displayMode: .inline)
            }
        }
        .sheet(isPresented: $isSettingsShowing) {
            NavigationView {
                SettingsView(
                    isPresented: $isSettingsShowing,
                    store: store.scope(state: \.settings, action: Root.Action.settings),
                    newGameTrigger: { ViewStore(store, observe: { $0 }).send(.game(.createNewGame)) }
                )
                .navigationBarItems(leading: Button("Close") { isSettingsShowing.toggle() })
                .navigationBarTitle("Game Settings", displayMode: .inline)
            }
        }
        .onAppear {
            ViewStore(store, observe: { $0 }).send(.game(.loadGame))
            ViewStore(store, observe: { $0 }).send(.settings(.loadSettings))
        }
    }
}

// MARK: Custom button

private struct CustomButton: View {
    
    let action: (() -> Void)
    let image: Image
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image("sceneBg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 48, height: 48)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                image
                    .frame(width: 40, height: 40)
            }
        }
        .frame(width: 48, height: 48)
    }
}

// MARK: preview

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(store: StoreOf<Root>(initialState: Root.State()) { Root() })
    }
}
