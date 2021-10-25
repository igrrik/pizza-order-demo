//
//  AuthService.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.10.2021.
//

import Foundation
import RxSwift

typealias AuthToken = UUID

protocol AuthService: AnyObject {
    func auth(username: String, password: String) -> Single<AuthToken>
}
