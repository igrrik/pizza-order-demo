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
    let cartStore: CartStore
    let pizzaProvidingService: ProductProvidingService
    let drinksProvidingService: ProductProvidingService

    static func liveFactory() -> Self {
        let scheduler = MainScheduler.instance
        return AppModulesFactory(
            authService: LiveAuthService(),
            scheduler: scheduler,
            cartStore: CartStore(scheduler: scheduler),
            pizzaProvidingService: PizzaProvidingService(scheduler: scheduler),
            drinksProvidingService: DrinksProvidingService(scheduler: scheduler)
        )
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

    func makeCartListModule(moduleOutput: CartListModuleOutput) -> UIViewController {
        let vc = CartListViewController()
        vc.title = "Cart"
        
        let presenter = CartListPresenter()
        vc.viewOutput = presenter
        presenter.moduleOutput = moduleOutput
        presenter.viewInput = vc

        let interactor = CartListInteractor(cartStore: cartStore)
        presenter.interactor = interactor
        interactor.output = presenter

        return vc
    }

    func makePizzaListModule() -> UIViewController {
        let vc = makeListModule(productService: pizzaProvidingService)
        vc.title = "Pizza"
        return vc
    }

    func makeDrinksListModule() -> UIViewController {
        let vc = makeListModule(productService: drinksProvidingService)
        vc.title = "Drink"
        return vc
    }

    private func makeListModule(productService: ProductProvidingService) -> UIViewController {
        let stateDriver = cartStore.state
            .asDriver(onErrorRecover: { error in
                assertionFailure("Failed to convert cart store to Driver due to error: \(error)")
                return .just(.init())
            })
        let viewModel = ProductListViewModel(
            cartState: stateDriver,
            cartEventDispatcher: cartStore.dispatch(event:),
            productProvidingService: productService
        )
        return ProductListViewController(viewModel: viewModel)
    }
}

private extension AuthViewStateController {
    func authViewState() -> Observable<AuthViewState> {
        return Observable
            .deferred(observeState)
            .map { $0 as AuthViewState }            
    }
}
