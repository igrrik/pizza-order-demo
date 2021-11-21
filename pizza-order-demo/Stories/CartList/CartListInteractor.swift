//
//  CartListInteractor.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 21.11.2021.
//

import Foundation
import RxSwift

final class CartListInteractor: CartListInteractorInput {
    weak var output: CartListInteractorOutput?
    private let cartStore: CartStore
    private let disposeBag = DisposeBag()

    init(cartStore: CartStore) {
        self.cartStore = cartStore
    }

    func observeCartUpdates() {
        cartStore.state
            .map { Array($0.items.values) }
            .bind(onNext: { [weak self] items in
                self?.output?.cartDidUpdate(items)
            })
            .disposed(by: disposeBag)
    }

    func increaseItemCount(_ item: CartItem) {
        cartStore.dispatch(event: .add(product: item.product))
    }

    func decreaseItemCount(_ item: CartItem) {
        cartStore.dispatch(event: .remove(product: item.product))
    }

    func purchaseProducts() {
        output?.purchaseDidFinish(result: .failure(.unauthorized))
    }
}
