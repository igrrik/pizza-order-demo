//
//  CartListProtocols.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 21.11.2021.
//

import Foundation

protocol CartListModuleOutput: AnyObject {
    func openAuthorizationFlow()
}

protocol CartListViewInput: AnyObject {
    func updatePrice(_ price: String)
    func updatePurchaseButton(isActive: Bool)
    func updateDataSource(_ dataSource: [CartListTableViewCellModel])
}

protocol CartListViewOutput {
    func viewDidLoad()
    func didTapPurchaseButton()
}

protocol CartListInteractorInput {
    func observeCartUpdates()
    func increaseItemCount(_ item: CartItem)
    func decreaseItemCount(_ item: CartItem)
    func purchaseProducts()
}

protocol CartListInteractorOutput: AnyObject {
    func cartDidUpdate(_ items: [CartItem])
    func purchaseDidFinish(result: Result<Void, PurchaseError>)
}

enum PurchaseError: Error {
    case unauthorized
}
