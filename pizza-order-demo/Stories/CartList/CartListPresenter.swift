//
//  CartListPresenter.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 21.11.2021.
//

import Foundation

final class CartListPresenter {
    var interactor: CartListInteractorInput?
    weak var viewInput: CartListViewInput?

    private func convertItemsToCellModels(items: [CartItem]) -> [CartListTableViewCellModel] {
        items.map { item in
            CartListTableViewCellModel(
                price: "\(item.price) $",
                title: item.product.name,
                count: String(describing: item.count),
                productImage: item.product.image,
                onTapIncrement: { [weak self] in
                    self?.interactor?.increaseItemCount(item)
                },
                onTapDecrement: {
                    self.interactor?.decreaseItemCount(item)
                }
            )
        }
    }
}

extension CartListPresenter: CartListViewOutput {
    func viewDidLoad() {
        interactor?.observeCartUpdates()        
    }

    func didTapPurchaseButton() {
        interactor?.purchaseProducts()
    }
}

extension CartListPresenter: CartListInteractorOutput {
    func cartDidUpdate(_ items: [CartItem]) {
        viewInput?.updatePurchaseButton(isActive: !items.isEmpty)
        viewInput?.updatePrice("\(items.totalPrice) $")
        viewInput?.updateDataSource(convertItemsToCellModels(items: items))
    }

    func failedToProceedPurchase(error: Error) {
        viewInput?.displayError(error)
    }
}

extension Array where Element == CartItem {
    var totalPrice: Int { map(\.price).reduce(0, +) }
}
