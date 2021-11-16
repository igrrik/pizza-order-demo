//
//  ProductItemCollectionViewModel.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 14.11.2021.
//

import UIKit
import RxCocoa
import RxFeedback

final class ProductItemCollectionViewModel {

    enum Event: Equatable {
        case increment
        case decrement
    }

    let price: Driver<String>
    let productImage: Driver<UIImage>
    let count: Driver<String>
    let isAddToCartButtonVisible: Driver<Bool>

    private let eventHandler: (Event) -> Void

    init(data: Driver<CartItem>, eventHandler: @escaping (Event) -> Void) {
        self.eventHandler = eventHandler
        self.price = data.map { "\($0.product.price) $" }
        self.productImage = data.map { $0.product.image }
        self.count = data.map { "\($0.count)" }
        self.isAddToCartButtonVisible = data.map { $0.count == 0 }
    }

    func dispatch(event: Event) {
        eventHandler(event)
    }
}
