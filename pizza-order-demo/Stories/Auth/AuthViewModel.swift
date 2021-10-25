//
//  AuthViewModel.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.10.2021.
//

import Foundation
import RxSwift
import RxCocoa

protocol AuthViewState {
    var isButtonEnabled: Bool { get }
    var username: String { get }
    var password: String { get }
    var error: String? { get }
}

enum AuthViewUIEvent: Equatable {
    case didChangeUsername(String)
    case didChangePassword(String)
    case didTapSignInButton
}

final class AuthViewModel {
    private(set) lazy var error: Signal<String> = state.compactMap { $0.error }.asSignal(onErrorJustReturn: "")
    private(set) lazy var username: Driver<String> = state.map { $0.username }.asDriver(onErrorJustReturn: "")
    private(set) lazy var password: Driver<String> = state.map { $0.password }.asDriver(onErrorJustReturn: "")
    private(set) lazy var isButtonEnabled: Driver<Bool> = state.map { $0.isButtonEnabled }.asDriver(onErrorJustReturn: false)

    private let state: Observable<AuthViewState>
    private let dispatchUIEvent: (AuthViewUIEvent) -> Void

    init(state: Observable<AuthViewState>, dispatchUIEvent: @escaping (AuthViewUIEvent) -> Void) {
        self.state = state.share(replay: 1)
        self.dispatchUIEvent = dispatchUIEvent
    }

    func dispatch(event: AuthViewUIEvent) {
        dispatchUIEvent(event)
    }
}
