//
//  LineApp.swift
//  Line
//
//  Created by tiennv166 on 12/06/2023.
//

import SwiftUI
import ComposableArchitecture

@main
struct LineApp: App {
    var body: some Scene {
        WindowGroup {
            RootView(
                store: StoreOf<Root>(initialState: Root.State()) {
                    Root()
                        ._printChanges()
                }
            )
        }
    }
}
