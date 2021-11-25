//
//  CartStoreTests.swift
//  pizza-order-demoTests
//
//  Created by Igor Kokoev on 22.11.2021.
//

import Foundation
import XCTest
import RxSwift
import RxTest
import RxFeedback
@testable import pizza_order_demo

final class CartStoreTests: XCTestCase {
    private var cartStore: CartStore!
    private var testScheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        try super.setUpWithError()
        disposeBag = .init()
        testScheduler = .init(initialClock: .zero)
        cartStore = .init(scheduler: testScheduler)
    }

    func testThatItemIsAddedToCart() {
        //
        // Arrange
        //
        let expectedPrice = [Product.cola, Product.cola, Product.beer].totalPrice
        let expectedEvents: [Recorded<Event<CartStore.State>>] = [
            .next(1, .init()),
            .next(6, .init([.cola: 1])),
            .next(11, .init([.cola: 2])),
            .next(16, .init([.cola: 2, .beer: 1])),
        ]

        let observer = testScheduler.createObserver(CartStore.State.self)
        cartStore.state
            .asObservable()
            .subscribe(observer)
            .disposed(by: disposeBag)

        //
        // Act
        //
        testScheduler.scheduleAt(5) {
            self.cartStore.dispatch(event: .add(product: .cola))
        }
        testScheduler.scheduleAt(10) {
            self.cartStore.dispatch(event: .add(product: .cola))
        }
        testScheduler.scheduleAt(15) {
            self.cartStore.dispatch(event: .add(product: .beer))
        }
        testScheduler.start()

        //
        // Assert
        //
        let receivedEvents = observer.events
        XCTAssertEqual(receivedEvents, expectedEvents)
        guard let lastEvent = receivedEvents.last?.value, case let .next(state) = lastEvent else {
            XCTFail()
            return
        }

        XCTAssertEqual(state.price, expectedPrice)
    }

    func testThatItemIsDecremented() {
        //
        // Arrange
        //
        cartStore = .init(
            initialState: .init([.cola: 2]),
            scheduler: testScheduler
        )
        let expectedEvents: [Recorded<Event<CartStore.State>>] = [
            .next(1, .init([.cola: 2])),
            .next(6, .init([.cola: 1]))
        ]

        let observer = testScheduler.createObserver(CartStore.State.self)
        cartStore.state
            .asObservable()
            .subscribe(observer)
            .disposed(by: disposeBag)

        //
        // Act
        //
        testScheduler.scheduleAt(5) {
            self.cartStore.dispatch(event: .remove(product: .cola))
        }
        testScheduler.start()

        //
        // Assert
        //
        let receivedEvents = observer.events
        XCTAssertEqual(receivedEvents, expectedEvents)
        guard let lastEvent = receivedEvents.last?.value, case let .next(state) = lastEvent else {
            XCTFail()
            return
        }
        XCTAssertEqual(state.price, Product.cola.price)
    }

    func testThatItemIsRemoved() {
        //
        // Arrange
        //
        cartStore = .init(
            initialState: .init([.cola: 1]),
            scheduler: testScheduler
        )
        let expectedEvents: [Recorded<Event<CartStore.State>>] = [
            .next(1, .init([.cola: 1])),
            .next(6, .init())
        ]

        let observer = testScheduler.createObserver(CartStore.State.self)
        cartStore.state
            .asObservable()
            .subscribe(observer)
            .disposed(by: disposeBag)

        //
        // Act
        //
        testScheduler.scheduleAt(5) {
            self.cartStore.dispatch(event: .remove(product: .cola))
        }
        testScheduler.start()

        //
        // Assert
        //
        let receivedEvents = observer.events
        XCTAssertEqual(receivedEvents, expectedEvents)
        guard let lastEvent = receivedEvents.last?.value, case let .next(state) = lastEvent else {
            XCTFail()
            return
        }
        XCTAssertEqual(state.price, 0)
    }
}

private extension CartStore.State {
    init(_ items: [Product: Int]) {
        let data: [Product: CartItem] = items.reduce(into: [:]) { result, args in
            let (product, count) = args
            result[product] = CartItem(product: product, count: count)
        }
        self.init(items: data)
    }
}

private extension Array where Element == Product {
    var totalPrice: Int { map(\.price).reduce(0, +) }
}
