//
//  AuthViewModelTests.swift
//  pizza-order-demoTests
//
//  Created by Igor Kokoev on 23.11.2021.
//

import XCTest
import RxSwift
import RxTest
@testable import pizza_order_demo

final class AuthViewModelTests: XCTestCase {
    private var viewModel: AuthViewModel!
    private var disposeBag: DisposeBag!
    private var testScheduler: TestScheduler!

    override func setUpWithError() throws {
        try super.setUpWithError()
        disposeBag = .init()
        viewModel = .init(
            initialState: <#T##AuthViewModel.State#>,
            authService: <#T##AuthService#>,
            scheduler: <#T##SchedulerType#>
        )
    }
}

private final class AuthServiceMock: AuthService {
    var authUsernamePassword

    func auth(username: String, password: String) -> Single<AuthToken> {

    }
}
