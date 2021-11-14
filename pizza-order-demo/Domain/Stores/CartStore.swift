//
//  CartStore.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 15.11.2021.
//

import Foundation
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
    private let eventsStream: PublishRelay<Event>

    init(scheduler: SchedulerType) {
        let eventsStream = PublishRelay<Event>()

        self.state = Observable.system(
            initialState: State(),
            reduce: Self.reduce(state:event:),
            scheduler: scheduler,
            feedback: [{ _ in eventsStream.asObservable() }]
        )
        .distinctUntilChanged()
        .asInfallible(onErrorRecover: { error in
            fatalError(error.localizedDescription)
        })

        self.eventsStream = eventsStream
    }

    func dispatch(event: Event) {
        // TODO: understand why events are sent 4 times
        eventsStream.accept(event)
    }

    static func reduce(state: State, event: Event) -> State {
        var state = state
        switch event {
        case .add(let pizza):
            let pizzaCount = state.pizzas[pizza] ?? 0
            state.pizzas[pizza] = pizzaCount + 1
        case .remove(let pizza):
            guard var pizzaCount = state.pizzas[pizza] else {
                assertionFailure("You can't remove pizza which count is zero")
                break
            }
            pizzaCount -= 1

            if pizzaCount > 0 {
                state.pizzas[pizza] = pizzaCount
            } else {
                state.pizzas.removeValue(forKey: pizza)
            }
        }
        return state
    }
}
