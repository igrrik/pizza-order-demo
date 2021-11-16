//
//  CartItem.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 16.11.2021.
//

import Foundation

struct CartItem {
    let product: Product
    var count: Int
    var price: Int { product.price * count }
}

extension CartItem: Hashable {
    var hashValue: Int { product.hashValue }

    func hash(into hasher: inout Hasher) {
        hasher.combine(product)
    }

    static func == (lhs: CartItem, rhs: CartItem) -> Bool {
        return lhs.product == rhs.product
    }
}
