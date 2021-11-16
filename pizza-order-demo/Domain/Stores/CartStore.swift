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
        var price: Int { items.values.map(\.price).reduce(0, +) }
        var items: [Product: CartItem] = [:]
    }

    enum Event {
        case add(product: Product)
        case remove(product: Product)
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
        .asInfallible(onErrorRecover: { error in
            fatalError(error.localizedDescription)
        })

        self.eventsStream = eventsStream
    }

    func dispatch(event: Event) {
        eventsStream.accept(event)
    }

    static func reduce(state: State, event: Event) -> State {
        var state = state
        switch event {
        case .add(let product):
            var cartItem = state.items[product] ?? CartItem(product: product, count: 0)
            cartItem.count += 1
            state.items[product] = cartItem
        case .remove(let product):
            guard var cartItem = state.items.removeValue(forKey: product) else {
                assertionFailure("You can't remove product which count is zero")
                break
            }
            cartItem.count -= 1

            if cartItem.count > 0 {
                state.items[product] = cartItem
            }
        }
        return state
    }
}
