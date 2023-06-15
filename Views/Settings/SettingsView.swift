//
//  SettingsView.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import ComposableArchitecture
import SwiftUI

struct SettingsView: View {
    
    @Binding var isPresented: Bool
    let store: StoreOf<Settings>
    let newGameTrigger: () -> Void

    var body: some View {
        WithViewStore(store) { viewStore in
            VStack(spacing: 12) {
                SettingButton(
                    text: viewStore.isSoundEnabled ? "Off Sound" : "On Sound",
                    action: { viewStore.send(.toggleSoundEnabaled) }
                )
                SettingButton(
                    text: viewStore.isNextBallsHidden ? "Show Next Balls" : "Hide Next Balls",
                    action: { viewStore.send(.toggleNextBallsHidden) }
                )
                SettingButton(
                    text: "New Game",
                    action: {
                        newGameTrigger()
                        isPresented = false
                    }
                )
            }
        }
    }
}

// MARK: Custom button

private struct SettingButton: View {
    
    let text: String
    let action: (() -> Void)
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Image("sceneBg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 200, height: 48)
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                Text(text)
                    .frame(width: 200)
                    .font(
                        .system(size: 18)
                        .weight(.bold)
                    )
                    .foregroundColor(.black)
                    .padding()
            }
        }
        .frame(width: 200, height: 48)
    }
}

// MARK: SettingsView_Previews

struct SettingsView_Previews: PreviewProvider {
    @State static var isPresented = true

    static var previews: some View {
        SettingsView(
            isPresented: $isPresented,
            store: StoreOf<Settings>(initialState: Settings.State()) {
                Settings()
            },
            newGameTrigger: {}
        )
    }
}
