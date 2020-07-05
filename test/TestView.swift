//
//  TestView.swift
//  test
//
//  Created by Szymon Wójcik on 05/07/2020.
//  Copyright © 2020 Szymon Wójcik. All rights reserved.
//

import SwiftUI

struct TestView: View {
    @EnvironmentObject var store: SessionStore
    
    var body: some View {
        Button(
            action: {
                self.store.send(.emailChanged(UUID().uuidString))
            },
            label: {
                Text(store.state.email ?? "test")
            }
        )
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
