//
//  LivePizzaProvidingService.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 15.11.2021.
//

import Foundation
import RxSwift

final class LivePizzaProvidingService: PizzaProvidingService {
    func obtainPizzas() -> Single<[Pizza]> {
        .just(Pizza.allPizzas)
        .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
