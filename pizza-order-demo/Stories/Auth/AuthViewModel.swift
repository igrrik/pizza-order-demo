//
//  AuthViewModel.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.10.2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

final class AuthViewModel {
    private(set) lazy var error: Signal<String> = state.compactMap { $0.error }.asSignal(onErrorJustReturn: "")
    private(set) lazy var username: Driver<String> = state.map { $0.username }.asDriver(onErrorJustReturn: "")
    private(set) lazy var password: Driver<String> = state.map { $0.password }.asDriver(onErrorJustReturn: "")
    private(set) lazy var isButtonEnabled: Driver<Bool> = state.map { $0.isButtonEnabled }.asDriver(onErrorJustReturn: false)

    private let authService: AuthService
    private let scheduler: SchedulerType
    private let eventsStream = PublishRelay<Event>()
    private let initialState: State
    private lazy var state: Driver<State> = Driver.system(
        initialState: initialState,
        reduce: Self.reduce(state:event:),
        feedback: feedbacks()
    )

    init(initialState: State, authService: AuthService, scheduler: SchedulerType) {
        self.authService = authService
        self.scheduler = scheduler
        self.initialState = initialState
    }

    func change(username: String) {
        eventsStream.accept(.didChangeUsername(username))
    }

    func change(password: String) {
        eventsStream.accept(.didChangeUsername(password))
    }

    func signIn() {
        eventsStream.accept(.didTapSignInButton)
    }
}

extension AuthViewModel {
    private typealias Feedback = (Driver<State>) -> Signal<Event>

    struct State: Equatable {
        var isButtonEnabled: Bool { !username.isEmpty && !password.isEmpty }
        var username: String
        var password: String
        var error: String?
        var authToken: AuthToken?
        var shouldProcessAuth: AuthRequest?
    }

    enum Event {
        case didChangeUsername(String)
        case didChangePassword(String)
        case didTapSignInButton
        case authResult(Result<AuthToken, Error>)
    }

    struct AuthRequest: Equatable {
        let username: String
        let password: String
    }

    private static func reduce(state: State, event: Event) -> State {
        var state = state

        state.shouldProcessAuth = nil
        state.error = nil

        switch event {
        case .didTapSignInButton:
            state.shouldProcessAuth = .init(username: state.username, password: state.password)
        case .didChangeUsername(let username):
            state.username = username
        case .didChangePassword(let password):
            state.password = password
        case .authResult(let result):
            switch result {
            case .success(let token):
                state.authToken = token
            case .failure(let error):
                state.error = error.localizedDescription
            }
        }

        return state
    }

    private func feedbacks() -> [Feedback] {
        return [
            observeUIEvents(),
            performSignIn()
        ]
    }

    private func observeUIEvents() -> Feedback {
        return { _ in self.eventsStream.asSignal() }
    }

    private func performSignIn() -> Feedback {
        return react(request: { $0.shouldProcessAuth }, effects: { [authService] payload in
            return authService
                .auth(username: payload.username, password: payload.password)
                .map { Event.authResult(.success($0)) }
                .asSignal(onErrorRecover: { error in
                    return .just(Event.authResult(.failure(error)))
                })
        })
    }
}
