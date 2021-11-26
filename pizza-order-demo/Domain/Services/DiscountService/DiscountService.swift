//
//  DiscountService.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.11.2021.
//

import Foundation
import RxSwift

protocol DiscountService {
    func obtainDiscount(for items: [CartItem]) -> Single<Double>
}
