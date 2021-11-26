//
//  MockDiscountService.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.11.2021.
//

import Foundation
import RxSwift

final class MockDiscountService: DiscountService {
    var obtainDiscountForItemsResult: Single<Double> = .error(RxError.unknown)

    func obtainDiscount(for items: [CartItem]) -> Single<Double> {
        return obtainDiscountForItemsResult
    }
}
