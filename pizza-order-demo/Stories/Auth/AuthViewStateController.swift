//
//  AuthViewStateController.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.10.2021.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa

final class AuthViewStateController {

    typealias Feedback = (ObservableSchedulerContext<State>) -> Observable<Event>

    struct State: AuthViewState, Equatable {
        var isButtonEnabled: Bool { !username.isEmpty && !password.isEmpty }
        var username: String
        var password: String
        var error: String?
        var authToken: AuthToken?
        var shouldProcessAuth: AuthRequest?

        static var empty: State { .init(username: "", password: "") }
    }

    struct AuthRequest: Equatable {
        let username: String
        let password: String
    }

    enum Event {
        case uiEvent(AuthViewUIEvent)
        case authResult(Result<AuthToken, Error>)
    }

    private let authService: AuthService
    private let uiEventsStream: Observable<AuthViewUIEvent>
    private let scheduler: SchedulerType

    init(authService: AuthService, scheduler: SchedulerType, uiEventsStream: Observable<AuthViewUIEvent>) {
        self.authService = authService
        self.uiEventsStream = uiEventsStream
        self.scheduler = scheduler
    }
}

extension AuthViewStateController {
    func observeState() -> Observable<State> {
        Observable.system(
            initialState: State.empty,
            reduce: Self.reduce(state:event:),
            scheduler: scheduler,
            feedback: feedbacks()
        )
        .distinctUntilChanged()
    }

    private static func reduce(state: State, event: Event) -> State {
        var state = state

        state.shouldProcessAuth = nil
        state.error = nil

        switch event {
        case .uiEvent(let event):
            switch event {
            case .didTapSignInButton:
                state.shouldProcessAuth = .init(username: state.username, password: state.password)
            case .didChangeUsername(let username):
                state.username = username
            case .didChangePassword(let password):
                state.password = password
            }
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
            signIn()
        ]
    }

    private func observeUIEvents() -> Feedback {
        return { _ in self.uiEventsStream.map(Event.uiEvent) }
    }

    private func signIn() -> (ObservableSchedulerContext<State>) -> Observable<Event> {
        return react(request: { $0.shouldProcessAuth }, effects: { [authService] payload in
            return authService
                .auth(username: payload.username, password: payload.password)
                .asObservable()
                .map { Event.authResult(.success($0)) }
                .catch { .just(Event.authResult(.failure($0))) }
        })
    }
}
