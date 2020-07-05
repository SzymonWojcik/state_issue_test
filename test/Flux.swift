//
//  Flux.swift
//  test
//
//  Created by Szymon Wójcik on 05/07/2020.
//  Copyright © 2020 Szymon Wójcik. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

public typealias Reducer<State, Action, Environment> =
    (inout State, Action, Environment) -> AnyPublisher<Action, Never>?

public final class Store<State, Action, Environment>: ObservableObject {
    @Published public private(set) var state: State

    private let environment: Environment
    private let reducer: Reducer<State, Action, Environment>
    private var effectCancellables: Set<AnyCancellable> = []
    private var derivedCancellable: AnyCancellable?

    public init(
        initialState: State,
        reducer: @escaping Reducer<State, Action, Environment>,
        environment: Environment
    ) {
        self.state = initialState
        self.reducer = reducer
        self.environment = environment
    }

    public func send(_ action: Action) {
        guard let effect = reducer(&state, action, environment) else {
            return
        }

        effect
            .receive(on: DispatchQueue.main)
            .sink(receiveValue: send)
            .store(in: &effectCancellables)
    }
}

extension Store {
    public func binding<Value>(
        for keyPath: KeyPath<State, Value>,
        toAction: @escaping (Value) -> Action
    ) -> Binding<Value> {
        Binding<Value> (
            get: { self.state[keyPath: keyPath] },
            set: { self.send(toAction($0)) }
        )
    }
}

extension Store {
    public func derived<DerivedState: Equatable, DerivedAction, DerivedEnvironment>(
        deriveState: @escaping (State) -> DerivedState,
        deriveAction: @escaping (DerivedAction) -> Action,
        deriveEnvironment: @escaping (Environment) -> DerivedEnvironment
    ) -> Store<DerivedState, DerivedAction, DerivedEnvironment> {
        let store = Store<DerivedState, DerivedAction, DerivedEnvironment>(
            initialState: deriveState(state),
            reducer: { [weak self] _, action, _ in
                self?.send(deriveAction(action))
                return Empty(completeImmediately: true)
                    .eraseToAnyPublisher()
            },
            environment: deriveEnvironment(environment)
        )

        store.derivedCancellable = $state
            .map(deriveState)
            .removeDuplicates()
            .sink { [weak store] in store?.state = $0 }

        return store
    }
}
