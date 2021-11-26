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
            .bind(onNext: { [weak self] state in
                self?.processCartUpdate(state)
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

    private func processCartUpdate(_ state: CartStore.State) {
        output?.cartItemsDidUpdate(Array(state.items.values))
        output?.cartPriceDidUpdate(.init(cartState: state))
    }
}

private extension CartListModulePrice {
    init(cartState: CartStore.State) {
        if cartState.discountPercent > 0 {
            self = .discount(newPrice: cartState.priceWithDiscount, oldPrice: cartState.itemsPrice)
        } else {
            self = .plain(cartState.itemsPrice)
        }
    }
}
