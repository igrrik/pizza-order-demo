//
//  AppModulesFactory.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.10.2021.
//

import UIKit
import RxSwift
import RxRelay

struct AppModulesFactory {
    let authService: AuthService
    let scheduler: SchedulerType

    static func liveFactory() -> Self {
        AppModulesFactory(authService: LiveAuthService(), scheduler: MainScheduler.instance)
    }

    func makeAuthModule() -> UIViewController {
        let uiEventsStream = PublishRelay<AuthViewUIEvent>()
        let stateController = AuthViewStateController(
            authService: authService,
            scheduler: scheduler,
            uiEventsStream: uiEventsStream.asObservable()
        )
        let state = stateController.authViewState()
        let viewModel = AuthViewModel(state: state, dispatchUIEvent: uiEventsStream.accept(_:))
        return AuthViewController(viewModel: viewModel)
    }

    func makePizzaListModule() -> UIViewController {
        let viewModel = PizzaListViewModel()
        return PizzaListViewController(viewModel: viewModel)
    }
}

private extension AuthViewStateController {
    func authViewState() -> Observable<AuthViewState> {
        return Observable
            .deferred(observeState)
            .map { $0 as AuthViewState }            
    }
}
