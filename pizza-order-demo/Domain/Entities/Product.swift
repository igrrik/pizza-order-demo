//
//  Product.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 16.11.2021.
//

import UIKit

struct Product: Hashable {
    let name: String
    let price: Double
    let image: UIImage
    let category: Category
}

extension Product {
    enum Category: Equatable {
        case drink
        case pizza
    }
}
