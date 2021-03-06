//
//  CartListPresenter.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 21.11.2021.
//

import Foundation

final class CartListPresenter {
    var interactor: CartListInteractorInput?
    weak var moduleOutput: CartListModuleOutput?
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
    func cartItemsDidUpdate(_ items: [CartItem]) {
        viewInput?.updatePurchaseButton(isActive: !items.isEmpty)
        viewInput?.updateDataSource(convertItemsToCellModels(items: items))
    }

    func cartPriceDidUpdate(_ price: CartListModulePrice) {
        viewInput?.updatePrice(price)
    }

    func purchaseDidFinish(result: Result<Void, PurchaseError>) {
        switch result {
        case .success:
            print("Purchased successfully")
        case .failure:
            moduleOutput?.openAuthorizationFlow()
        }
    }
}
