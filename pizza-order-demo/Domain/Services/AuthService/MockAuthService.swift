//
//  MockAuthService.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.11.2021.
//

import Foundation
import RxSwift

final class MockAuthService: AuthService {
    var authUsernamePasswordResult: Single<AuthToken> = .error(RxError.unknown)

    func auth(username: String, password: String) -> Single<AuthToken> {
        return authUsernamePasswordResult
    }
}
