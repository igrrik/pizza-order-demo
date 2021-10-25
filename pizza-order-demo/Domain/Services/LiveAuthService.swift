//
//  LiveAuthService.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.10.2021.
//

import Foundation
import RxSwift

final class LiveAuthService: AuthService {
    func auth(username: String, password: String) -> Single<AuthToken> {
        guard username == "udf", password == "isAwesome" else {
            return .error(Failure.incorrectLoginPassword)
        }
        return .just(AuthToken())
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
    }
}

extension LiveAuthService {
    enum Failure: LocalizedError {
        case incorrectLoginPassword

        var errorDescription: String? {
            switch self {
            case .incorrectLoginPassword:
                return "Incorrect login or password"
            }
        }
    }
}
