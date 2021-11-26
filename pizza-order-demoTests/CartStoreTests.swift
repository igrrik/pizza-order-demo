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
    private var discountServiceMock: MockDiscountService!
    private var testScheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUpWithError() throws {
        try super.setUpWithError()
        disposeBag = .init()
        testScheduler = .init(initialClock: .zero)
        discountServiceMock = .init()
        cartStore = .init(scheduler: testScheduler, discountService: discountServiceMock)
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

        XCTAssertEqual(state.priceWithDiscount, expectedPrice)
    }

    func testThatItemIsDecremented() {
        //
        // Arrange
        //
        cartStore = .init(
            initialState: .init([.cola: 2]),
            scheduler: testScheduler,
            discountService: discountServiceMock
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
        XCTAssertEqual(state.priceWithDiscount, Product.cola.price)
    }

    func testThatItemIsRemoved() {
        //
        // Arrange
        //
        cartStore = .init(
            initialState: .init([.cola: 1]),
            scheduler: testScheduler,
            discountService: discountServiceMock
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
        XCTAssertEqual(state.priceWithDiscount, 0)
    }

    func testThatDiscountIsApplied() {
        //
        // Arrange
        //
        let expectedEvents: [Recorded<Event<CartStore.State>>] = [
            .next(1, .init()),
            .next(6, .init([.fiveDollarProduct: 1])),
            .next(7, .init([.fiveDollarProduct: 1], discountPercent: 10)),
            .next(11, .init([.fiveDollarProduct: 1, .tenDollarProduct: 1], discountPercent: 10)),
            .next(12, .init([.fiveDollarProduct: 1, .tenDollarProduct: 1], discountPercent: 20))
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
            self.discountServiceMock.obtainDiscountForItemsResult = .just(10.0)
            self.cartStore.dispatch(event: .add(product: .fiveDollarProduct))
        }
        testScheduler.scheduleAt(10) {
            self.discountServiceMock.obtainDiscountForItemsResult = .just(20.0)
            self.cartStore.dispatch(event: .add(product: .tenDollarProduct))
        }
        testScheduler.start()

        //
        // Assert
        //
        let receivedEvents = observer.events
        XCTAssertEqual(receivedEvents, expectedEvents)
        let priceWithDiscounts: [Double] = receivedEvents.compactMap { event in
            switch event.value {
            case .next(let state):
                return state.priceWithDiscount
            default:
                return nil
            }
        }
        XCTAssertEqual(priceWithDiscounts, [0.0, 5.0, 4.5, 13.5, 12])
    }
}

private extension CartStore.State {
    init(_ items: [Product: Int], discountPercent: Double = 0.0) {
        let data: [Product: CartItem] = items.reduce(into: [:]) { result, args in
            let (product, count) = args
            result[product] = CartItem(product: product, count: count)
        }
        self.init(items: data, discountPercent: discountPercent)
    }
}

private extension Array where Element == Product {
    var totalPrice: Double { map(\.price).reduce(0.0, +) }
}

private extension Product {
    static let fiveDollarProduct = Product(name: "five", price: 5.0, image: UIImage(), category: .pizza)
    static let tenDollarProduct = Product(name: "ten", price: 10.0, image: UIImage(), category: .drink)
}
