//
//  AuthViewModelTests.swift
//  pizza-order-demoTests
//
//  Created by Igor Kokoev on 23.11.2021.
//

import XCTest
import RxSwift
import RxTest
import RxCocoa
@testable import pizza_order_demo

final class AuthViewModelTests: XCTestCase {
    private var authServiceMock: MockAuthService!
    private var disposeBag: DisposeBag!
    private var testScheduler: TestScheduler!

    override func setUpWithError() throws {
        try super.setUpWithError()
        disposeBag = .init()
        authServiceMock = .init()
        testScheduler = .init(initialClock: .zero, simulateProcessingDelay: false)        
    }

    func testThatUsernameIsChanged() {
        //
        // Arrange
        //
        let viewModel = makeViewModel(initialState: .init(username: "", password: ""))
        let observer = makeDriverObserver(from: viewModel, at: \.username)

        //
        // Act
        //
        testScheduler.scheduleAt(5) {
            viewModel.change(username: "John")
        }
        testScheduler.scheduleAt(10) {
            viewModel.change(username: "Alex")
        }
        testScheduler.start()

        //
        // Assert
        //
        let receivedEvents = observer.events
        XCTAssertEqual(receivedEvents, [.next(5, "John"), .next(10, "Alex")])
    }

    func testThatPasswordIsChanged() {
        //
        // Arrange
        //
        let viewModel = makeViewModel(initialState: .init(username: "", password: ""))
        let observer = makeDriverObserver(from: viewModel, at: \.password)

        //
        // Act
        //
        testScheduler.scheduleAt(5) {
            viewModel.change(password: "admin")
        }
        testScheduler.scheduleAt(10) {
            viewModel.change(password: "password")
        }
        testScheduler.start()

        //
        // Assert
        //
        let receivedEvents = observer.events
        XCTAssertEqual(receivedEvents, [.next(5, "admin"), .next(10, "password")])
    }

    func testThatSignInButtonIsEnabledWhenUsernameAndPasswordAreNotEmpty() {
        //
        // Arrange
        //
        let viewModel = makeViewModel(initialState: .init(username: "", password: ""))
        let observer = makeDriverObserver(from: viewModel, at: \.isButtonEnabled)

        //
        // Act
        //
        testScheduler.scheduleAt(5) {
            viewModel.change(username: "admin")
        }
        testScheduler.scheduleAt(10) {
            viewModel.change(password: "password")
        }
        testScheduler.scheduleAt(15) {
            viewModel.change(password: "")
        }
        testScheduler.start()

        //
        // Assert
        //
        let receivedEvents = observer.events
        XCTAssertEqual(receivedEvents, [.next(5, false), .next(10, true), .next(15, false)])
    }

    func testThatAuthFailed() {
        //
        // Arrange
        //
        authServiceMock.authUsernamePasswordResult = .error(CommonError("Auth failed"))
        let viewModel = makeViewModel(initialState: .init(username: "admin", password: "password"))
        let observer = makeSignalObserver(from: viewModel, at: \.error)

        //
        // Act
        //
        testScheduler.scheduleAt(5) {
            viewModel.signIn()
        }
        testScheduler.start()

        //
        // Assert
        //
        let receivedEvents = observer.events
        XCTAssertEqual(receivedEvents, [.next(5, "Auth failed")])
    }

    func testThatAuthSucceeded() {
        //
        // Arrange
        //
        authServiceMock.authUsernamePasswordResult = .just(UUID())
        let viewModel = makeViewModel(initialState: .init(username: "admin", password: "password"))
        let observer = makeSignalObserver(from: viewModel, at: \.success)

        //
        // Act
        //
        testScheduler.scheduleAt(5) {
            viewModel.signIn()
        }
        testScheduler.start()

        //
        // Assert
        //
        let receivedEvents = observer.events
        XCTAssertFalse(receivedEvents.isEmpty)
    }

    private func makeDriverObserver<T>(
        from viewModel: AuthViewModel,
        at keyPath: KeyPath<AuthViewModel, Driver<T>>
    ) -> TestableObserver<T> {
        let observer = testScheduler.createObserver(T.self)
        viewModel[keyPath: keyPath]
            .skip(1)
            .drive(observer)
            .disposed(by: disposeBag)

        return observer
    }

    private func makeSignalObserver<T>(
        from viewModel: AuthViewModel,
        at keyPath: KeyPath<AuthViewModel, Signal<T>>
    ) -> TestableObserver<T> {
        let observer = testScheduler.createObserver(T.self)
        viewModel[keyPath: keyPath]
            .emit(to: observer)
            .disposed(by: disposeBag)

        return observer
    }

    private func makeViewModel(initialState: AuthViewModel.State) -> AuthViewModel {
        return .init(initialState: initialState, authService: authServiceMock, scheduler: testScheduler)
    }
}

private struct CommonError: LocalizedError {
    let errorDescription: String?

    init(_ description: String) {
        errorDescription = description
    }
}
