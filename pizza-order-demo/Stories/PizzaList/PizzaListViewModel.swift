//
//  PizzaListViewModel.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 30.10.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class CartStore {

    struct State: Equatable {
        var price: Int { pizzas.map { $0.key.price * $0.value }.reduce(0, +) }
        var pizzas: [Pizza: Int] = [:]
    }

    enum Event {
        case add(pizza: Pizza)
        case remove(pizza: Pizza)
    }

    let state: Infallible<State>

    init(scheduler: SchedulerType, eventsStream: Infallible<Event>) {
        state = Observable.system(
            initialState: State(),
            reduce: { (state: State, event: Event) in
                var state = state
                switch event {
                case .add(let pizza):
                    state.pizzas[pizza]! += 1
                case .remove(let pizza):
                    state.pizzas[pizza]! -= 1
                }
                return state
            },
            scheduler: scheduler,
            feedback: [{ _ in eventsStream.asObservable() }]
        )
        .asInfallible(onErrorRecover: { error in
            fatalError(error.localizedDescription)
        })
    }
}

final class PizzaListViewModel {
    let dataSource: Driver<[PizzaItemCollectionViewModel]>
    let isProceedToCardButtonVisible

    init() {
        let items = [
            UIImage(named: "margarita"),
            UIImage(named: "barbeque"),
            UIImage(named: "four_seasons"),
            UIImage(named: "quattro_formagge"),
        ]
        .compactMap { $0 }
        .map(PizzaItemCollectionViewModel.init(pizzaImage:))

        self.dataSource = .just(items)
    }
}
