//
//  LiveDiscountService.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.11.2021.
//

import Foundation
import RxSwift

final class LiveDiscountService: DiscountService {
    func obtainDiscount(for items: [CartItem]) -> Single<Double> {
        let discountPercent: Double
        let itemsSet = Set(items.map(\.product))

        switch itemsSet.count {
        case 3...5:
            discountPercent = 10
        case 5...Int.max:
            discountPercent = 20
        default:
            discountPercent = 0
        }

        return .just(discountPercent)
    }
}
