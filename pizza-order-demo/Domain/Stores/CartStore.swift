//
//  CartStore.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 15.11.2021.
//

import Foundation
import RxSwift
import RxCocoa
import RxFeedback

final class CartStore {

    struct State: Equatable {
        var items: [Product: CartItem] = [:]
        var discountPercent: Double = 0.0
        var itemsPrice: Double { items.values.map(\.price).reduce(0, +)  }
        var priceWithDiscount: Double { itemsPrice * ((100 - discountPercent) / 100) }

        // Request
        var shouldLoadDiscount: [CartItem]? { items.isEmpty ? nil : Array(items.values) }
    }

    enum Event {
        case add(product: Product)
        case remove(product: Product)
        case didObtain(discount: Double)
    }

    private let initialState: State
    private let scheduler: ImmediateSchedulerType
    private let discountService: DiscountService
    private let eventsStream = PublishRelay<Event>()

    private(set) lazy var state: Infallible<State> = {
        return Observable.system(
            initialState: initialState,
            reduce: CartStore.reduce,
            scheduler: scheduler,
            feedback: [observeExternalEvents(), obtainDiscount()]
        )
        .asInfallible(onErrorRecover: { error in
            fatalError(error.localizedDescription)
        })
        .share(replay: 1)
    }()

    init(initialState: State = State(), scheduler: SchedulerType, discountService: DiscountService) {
        self.initialState = initialState
        self.discountService = discountService
        self.scheduler = scheduler
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
                assertionFailure("You can't remove product, that isn't presented in Cart")
                break
            }
            cartItem.count -= 1

            if cartItem.count > 0 {
                state.items[product] = cartItem
            }
        case .didObtain(let discount):
            state.discountPercent = discount
        }
        return state
    }

    private func observeExternalEvents() -> (ObservableSchedulerContext<State>) -> Observable<Event> {
        return { _ in self.eventsStream.asObservable() }
    }

    private func obtainDiscount() -> (ObservableSchedulerContext<State>) -> Observable<Event> {
        react(request: { $0.shouldLoadDiscount }, effects: { [unowned self] items in
            self.discountService
                .obtainDiscount(for: items)
                .map { Event.didObtain(discount: $0) }
                .asObservable()
                .catch { _ in .empty() }
        })
    }
}
