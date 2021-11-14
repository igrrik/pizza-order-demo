//
//  PizzaItemCollectionViewModel.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 14.11.2021.
//

import UIKit
import RxCocoa
import RxFeedback

final class PizzaItemCollectionViewModel {

    struct Data: Equatable {
        let pizza: Pizza
        let count: Int
    }

    enum Event: Equatable {
        case increment
        case decrement
    }

    let price: Driver<String>
    let pizzaImage: Driver<UIImage>
    let count: Driver<String>
    let isAddToCartButtonVisible: Driver<Bool>

    private let eventHandler: (Event) -> Void

    init(data: Driver<Data>, eventHandler: @escaping (Event) -> Void) {
        self.eventHandler = eventHandler
        self.price = data.map { "\($0.pizza.price) $" }
        self.pizzaImage = data.map { $0.pizza.image }
        self.count = data.map { "\($0.count)" }
        self.isAddToCartButtonVisible = data.map { $0.count == 0 }
    }

    func dispatch(event: Event) {
        eventHandler(event)
    }
}
