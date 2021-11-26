//
//  PizzaProvidingService.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 15.11.2021.
//

import UIKit
import RxSwift

final class PizzaProvidingService: ProductProvidingService {
    private let scheduler: SchedulerType

    init(scheduler: SchedulerType) {
        self.scheduler = scheduler
    }

    func obtainProducts() -> Single<[Product]> {
        .just(Product.allPizzas)
        .delay(.seconds(1), scheduler: scheduler)
    }
}

extension Product {
    fileprivate static let allPizzas: [Product] = [.margarita, .bbq, .fourSeasons, .quattroFormagge]

    static let margarita = pizza(name: "Margarita", price: 8.99, imageName: "margarita")
    static let bbq = pizza(name: "BBQ", price: 12.99, imageName: "barbeque")
    static let fourSeasons = pizza(name: "Four seasons", price: 17.99, imageName: "four_seasons")
    static let quattroFormagge = pizza(name: "Quattro Formagge", price: 11.49, imageName: "quattro_formagge")
}

private func pizza(name: String, price: Double, imageName: String) -> Product {
    .init(name: name, price: price, image: UIImage(named: imageName)!, category: .pizza)
}
