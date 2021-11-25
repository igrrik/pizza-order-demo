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
    private(set) lazy var username: Driver<String> = state.map { $0.username }.asDriver(onErrorJustReturn: "")
    private(set) lazy var password: Driver<String> = state.map { $0.password }.asDriver(onErrorJustReturn: "")
    private(set) lazy var isButtonEnabled: Driver<Bool> = state.map { $0.isButtonEnabled }.asDriver(onErrorJustReturn: false)
    private(set) lazy var error: Signal<String> = state.compactMap { $0.error }.asSignal(onErrorJustReturn: "")
    private(set) lazy var success: Signal<Void> = {
        state
            .compactMap { $0.authToken != nil ? Void() : nil }
            .asSignal(onErrorRecover: { _ in fatalError("Impossible state") })
    }()

    private let authService: AuthService
    private let scheduler: SchedulerType
    private let eventsStream = PublishRelay<Event>()
    private let initialState: State
    private lazy var state: Infallible<State> = {
        Observable.system(initialState: initialState, reduce: Self.reduce, scheduler: scheduler, feedback: feedbacks())
            .distinctUntilChanged()
            .asInfallible(onErrorRecover: { error in
                fatalError("Unexpected error: \(error)")
            })
            .share(replay: 1)
    }()

    init(initialState: State, authService: AuthService, scheduler: SchedulerType) {
        self.authService = authService
        self.scheduler = scheduler
        self.initialState = initialState
    }

    func change(username: String) {
        eventsStream.accept(.didChangeUsername(username))
    }

    func change(password: String) {
        eventsStream.accept(.didChangePassword(password))
    }

    func signIn() {
        eventsStream.accept(.didTapSignInButton)
    }
}

extension AuthViewModel {
    private typealias Feedback = (ObservableSchedulerContext<State>) -> Observable<Event>

    struct State: Equatable {
        var isButtonEnabled: Bool { !username.isEmpty && !password.isEmpty }
        var username: String
        var password: String
        var error: String?
        var authToken: AuthToken?
        var shouldPerformAuth: AuthRequest?
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

        state.shouldPerformAuth = nil
        state.error = nil

        switch event {
        case .didTapSignInButton:
            state.shouldPerformAuth = .init(username: state.username, password: state.password)
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
        return { _ in self.eventsStream.asObservable() }
    }

    private func performSignIn() -> Feedback {
        return react(request: {
            $0.shouldPerformAuth
        }, effects: { [authService] payload in
            return authService
                .auth(username: payload.username, password: payload.password)
                .map { Event.authResult(.success($0)) }
                .catch { .just(.authResult(.failure($0))) }
                .asObservable()
        })
    }
    
//    private func performSignIn() -> Feedback {
//        return { state in
//            self.eventsStream
//                .filter { event in
//                    switch event {
//                    case .didTapSignInButton:
//                        return true
//                    default:
//                        return false
//                    }
//                }
//                .withLatestFrom(state)
//                .flatMap { [unowned self] state in
//                    self.authService.auth(username: state.username, password: state.password)
//                }
//                .map { Event.authResult(.success($0)) }
//                .catch { .just(.authResult(.failure($0))) }
//        }
//    }
}
