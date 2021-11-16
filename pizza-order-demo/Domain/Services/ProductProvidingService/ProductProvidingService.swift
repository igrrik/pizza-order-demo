//
//  ProductProvidingService.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 15.11.2021.
//

import Foundation
import RxSwift

protocol ProductProvidingService {
    func obtainProducts() -> Single<[Product]>
}
