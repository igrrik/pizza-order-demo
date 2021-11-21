//
//  DrinksProvidingService.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 16.11.2021.
//

import UIKit
import RxSwift

final class DrinksProvidingService: ProductProvidingService {
    private let scheduler: SchedulerType

    init(scheduler: SchedulerType) {
        self.scheduler = scheduler
    }

    func obtainProducts() -> Single<[Product]> {
        .just(Product.allDrinks)
        .delay(.milliseconds(500), scheduler: scheduler)
    }
}

extension Product {
    fileprivate static let allDrinks: [Product] = [cola, beer, water, wine]

    static let cola = drink(name: "Coca-Cola", price: 7, imageName: "cola")
    static let beer = drink(name: "Corona", price: 14, imageName: "beer")
    static let water = drink(name: "BonAqua", price: 3, imageName: "water")
    static let wine = drink(name: "Wine", price: 59, imageName: "wine")
}

private func drink(name: String, price: Int, imageName: String) -> Product {
    .init(name: name, price: price, image: UIImage(named: imageName)!, category: .drink)
}
