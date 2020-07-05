//
//  ContentView.swift
//  test
//
//  Created by Szymon Wójcik on 05/07/2020.
//  Copyright © 2020 Szymon Wójcik. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    
    var body: some View {
        TestView()
            .environmentObject(
                self.store.derived(
                deriveState: \.sessionState,
                deriveAction: AppAction.session,
                deriveEnvironment: { _ in SessionEnvironment() }
            )
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
