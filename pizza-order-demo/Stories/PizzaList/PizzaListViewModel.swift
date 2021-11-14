//
//  PizzaListViewModel.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 30.10.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class PizzaListViewModel {
    let dataSource: Driver<[PizzaItemCollectionViewModel]>
    let totalPriceText: Driver<String> // TODO: bind
    let isProceedToCardButtonVisible: Driver<Bool> // TODO: bind
    let isLoadingIndicatorVisible: Driver<Bool> // TODO: bind
    let error: Signal<Error> // TODO: bind

    let dismissHandler: (() -> Void)?

    private let cartState: Driver<CartStore.State>
    private let errorRelay = PublishRelay<Error>()
    private let isLoadingIndicatorVisibleRelay = BehaviorRelay<Bool>(value: false)
    private let dataSourceRelay = BehaviorRelay<[PizzaItemCollectionViewModel]>(value: [])
    private let cartEventDispatcher: (CartStore.Event) -> Void
    private let pizzaProvidingService: PizzaProvidingService
    private let disposeBag = DisposeBag()

    init(
        cartState: Driver<CartStore.State>,
        cartEventDispatcher: @escaping (CartStore.Event) -> Void,
        pizzaProvidingService: PizzaProvidingService,
        dismissHandler: (() -> Void)?
    ) {
        self.cartState = cartState
        self.error = errorRelay.asSignal()
        self.isLoadingIndicatorVisible = isLoadingIndicatorVisibleRelay.asDriver()
        self.dataSource = dataSourceRelay.asDriver()
        self.dismissHandler = dismissHandler
        self.cartEventDispatcher = cartEventDispatcher
        self.pizzaProvidingService = pizzaProvidingService

        let price = cartState.map { $0.price }
        self.totalPriceText = price.map { "\($0) $" }.asDriver(onErrorJustReturn: "ERROR")
        self.isProceedToCardButtonVisible = price.map { $0 > 0 }.asDriver(onErrorJustReturn: false)
    }

    func loadPizzas() {
        isLoadingIndicatorVisibleRelay.accept(true)
        pizzaProvidingService
            .obtainPizzas()
            .map { [unowned self] pizzas -> [PizzaItemCollectionViewModel] in
                pizzas.map { self.mapPizzaToViewModel($0) }
            }
            .subscribe(onSuccess: { [weak self] viewModels in
                self?.dataSourceRelay.accept(viewModels)
            }, onFailure: { error in
                self.errorRelay.accept(error)
            }, onDisposed: { [weak self] in
                self?.isLoadingIndicatorVisibleRelay.accept(false)
            })
            .disposed(by: disposeBag)
    }

    private func mapPizzaToViewModel(_ pizza: Pizza) -> PizzaItemCollectionViewModel {
        let data = cartState
            .map { state -> PizzaItemCollectionViewModel.Data in
                let pizzaCount = state.pizzas[pizza] ?? 0
                return .init(pizza: pizza, count: pizzaCount)
            }
            .asDriver(onErrorRecover: { error in
                assertionFailure("Failed to convert pizza to viewModel due to error: \(error)")
                return .just(.init(pizza: pizza, count: 0))
            })

        return PizzaItemCollectionViewModel(
            data: data,
            eventHandler: { [weak self] event in
                print("???? event in model \(event)")
                switch event {
                case .increment:
                    self?.cartEventDispatcher(.add(pizza: pizza))
                case .decrement:
                    self?.cartEventDispatcher(.remove(pizza: pizza))
                }
            }
        )
    }
}
