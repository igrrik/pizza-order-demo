//
//  AuthViewModel.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.10.2021.
//

import Foundation
import RxSwift
import RxFeedback
import RxCocoa

final class AuthViewModel {
    private let authService: AuthService
    private lazy var state: Observable<State> = Observable.system(
        initialState: .empty,
        reduce: Self.reduce(state:event:),
        scheduler: MainScheduler.instance,
        feedback: [observeUIEvents(), signIn()]
    )
    .share()
    .distinctUntilChanged()

    private(set) lazy var error: Signal<String> = state.compactMap { $0.error }.asSignal(onErrorJustReturn: "")
    private(set) lazy var username: Driver<String> = state.map { $0.username }.asDriver(onErrorJustReturn: "")
    private(set) lazy var password: Driver<String> = state.map { $0.password }.asDriver(onErrorJustReturn: "")
    private(set) lazy var isButtonEnabled: Driver<Bool> = state.map { $0.isButtonEnabled }.asDriver(onErrorJustReturn: false)

    private let uiEvents = PublishRelay<Event>()

    init(authService: AuthService) {
        self.authService = authService
    }

    func didTapSignInButton() {
        uiEvents.accept(.didTapSignInButton)
    }

    func didChangeUsername(_ username: String) {
        uiEvents.accept(.didChangeUsername(username))
    }

    func didChangePassword(_ password: String) {
        uiEvents.accept(.didChangePassword(password))
    }

    private static func reduce(state: AuthViewModel.State, event: AuthViewModel.Event) -> AuthViewModel.State {

        print(event)

        var state = state

        state.shouldProcessAuth = nil

        switch event {
        case .didTapSignInButton:
            state.shouldProcessAuth = .init(username: state.username, password: state.password)
        case .didChangeUsername(let username):
            state.username = username
        case .didChangePassword(let password):
            state.password = password
        case .authSucceded(let token):
            state.authToken = token
        case .authFailed(let errorDescription):
            state.error = errorDescription
        }

        return state
    }

    private func observeUIEvents() -> (ObservableSchedulerContext<State>) -> Observable<Event> {
        return { _ in self.uiEvents.asObservable() }
    }

    private func signIn() -> (ObservableSchedulerContext<State>) -> Observable<Event> {
        return react(request: { $0.shouldProcessAuth }, effects: { [authService] payload in
            return authService
                .auth(username: payload.username, password: payload.password)
                .asObservable()
                .map(Event.authSucceded)
                .catch { error in
                    return .just(Event.authFailed(error.localizedDescription))
                }
        })
    }
}

private extension AuthViewModel {

    struct State: Equatable {
        var isButtonEnabled: Bool { !username.isEmpty && !password.isEmpty }
        var username: String
        var password: String
        var error: String?
        var shouldProcessAuth: AuthRequest?
        var authToken: AuthToken?

        static var empty: State {
            .init(username: "", password: "", error: nil)
        }
    }

    struct AuthRequest: Equatable {
        let username: String
        let password: String
    }

    enum Event {

        case didTapSignInButton
        case didChangeUsername(String)
        case didChangePassword(String)
        case authSucceded(AuthToken)
        case authFailed(String)
    }
}
