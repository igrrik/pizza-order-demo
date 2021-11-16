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
        var price: Int { products.map { $0.key.price * $0.value }.reduce(0, +) }
        var products: [Product: Int] = [:]
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
        .distinctUntilChanged()
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
            let productCount = state.products[product] ?? 0
            state.products[product] = productCount + 1
        case .remove(let product):
            guard var productCount = state.products[product] else {
                assertionFailure("You can't remove product which count is zero")
                break
            }
            productCount -= 1

            if productCount > 0 {
                state.products[product] = productCount
            } else {
                state.products.removeValue(forKey: product)
            }
        }
        return state
    }
}
