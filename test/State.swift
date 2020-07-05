//
//  State.swift
//  test
//
//  Created by Szymon Wójcik on 05/07/2020.
//  Copyright © 2020 Szymon Wójcik. All rights reserved.
//

import Combine

// MARK: State

struct AppState: Equatable {
    var sessionState = SessionState()
}

struct SessionState: Equatable {
    var email: String?
}

// MARK: Action

enum AppAction: Equatable {
    case session(SessionAction)
}

enum SessionAction: Equatable {
    case emailChanged(String?)
}

// MARK: Reducer

func appReducer(
    state: inout AppState,
    action: AppAction,
    environment: AppEnvironment
) -> AnyPublisher<AppAction, Never> {
    switch action {
    case .session(let sessionAction):
        return sessionReducer(
            state: &state.sessionState,
            action: sessionAction,
            environment: SessionEnvironment()
        )
        .map { AppAction.session($0) }
        .eraseToAnyPublisher()
    }
}

func sessionReducer(
    state: inout SessionState,
    action: SessionAction,
    environment: SessionEnvironment
) -> AnyPublisher<SessionAction, Never> {
    switch action {
    case .emailChanged(let email):
        state.email = email
        return Empty().eraseToAnyPublisher()
    }
}

// MARK: Environment

struct AppEnvironment {
    
}

struct SessionEnvironment {
    
}

typealias AppStore = Store<AppState, AppAction, AppEnvironment>
typealias SessionStore = Store<SessionState, SessionAction, SessionEnvironment>
