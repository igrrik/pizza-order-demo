//
//  ProductListViewModel.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 30.10.2021.
//

import UIKit
import RxSwift
import RxCocoa

final class ProductListViewModel {
    let dataSource: Driver<[ProductItemCollectionViewModel]>
    let isLoadingIndicatorVisible: Driver<Bool> // TODO: bind
    let error: Signal<Error> // TODO: bind

    private let cartState: Driver<CartStore.State>
    private let errorRelay = PublishRelay<Error>()
    private let isLoadingIndicatorVisibleRelay = BehaviorRelay<Bool>(value: false)
    private let dataSourceRelay = BehaviorRelay<[ProductItemCollectionViewModel]>(value: [])
    private let cartEventDispatcher: (CartStore.Event) -> Void
    private let productProvidingService: ProductProvidingService
    private let disposeBag = DisposeBag()

    init(
        cartState: Driver<CartStore.State>,
        cartEventDispatcher: @escaping (CartStore.Event) -> Void,
        productProvidingService: ProductProvidingService
    ) {
        self.cartState = cartState
        self.error = errorRelay.asSignal()
        self.isLoadingIndicatorVisible = isLoadingIndicatorVisibleRelay.asDriver()
        self.dataSource = dataSourceRelay.asDriver()
        self.cartEventDispatcher = cartEventDispatcher
        self.productProvidingService = productProvidingService
    }

    func loadProducts() {
        isLoadingIndicatorVisibleRelay.accept(true)
        productProvidingService
            .obtainProducts()
            .map { [unowned self] products -> [ProductItemCollectionViewModel] in
                products.map { self.mapProductToViewModel($0) }
            }
            .subscribe(onSuccess: { [weak self] viewModels in
                self?.dataSourceRelay.accept(viewModels)
            }, onFailure: { error in
                self.errorRelay.accept(error)
            }, onDisposed: { [weak self] in
                self?.isLoadingIndicatorVisibleRelay.accept(false)
            })
            .disposed(by: disposeBag)
    }

    private func mapProductToViewModel(_ product: Product) -> ProductItemCollectionViewModel {
        return ProductItemCollectionViewModel(
            data: cartState.compactMap { $0.items[product] },
            eventHandler: { [weak self] event in
                print("???? event in model \(event)")
                switch event {
                case .increment:
                    self?.cartEventDispatcher(.add(product: product))
                case .decrement:
                    self?.cartEventDispatcher(.remove(product: product))
                }
            }
        )
    }
}
