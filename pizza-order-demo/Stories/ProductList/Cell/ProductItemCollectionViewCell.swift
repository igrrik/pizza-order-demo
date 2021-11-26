//
//  ProductItemCollectionViewCell.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 29.10.2021.
//

import UIKit
import RxFeedback
import RxSwift
import RxCocoa

final class ProductItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet var productImageView: UIImageView!
    @IBOutlet var addToCartButton: UIButton!
    @IBOutlet var countActionsStackView: UIStackView!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var decrementButton: UIButton!
    @IBOutlet var incrementButton: UIButton!

    private var disposeBag = DisposeBag()

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = .init()
    }

    func configure(with model: ProductItemCollectionViewModel) {
        model.productImage
            .drive(productImageView.rx.image)
            .disposed(by: disposeBag)

        model.price
            .drive(addToCartButton.rx.title())
            .disposed(by: disposeBag)

        model.count
            .drive(countLabel.rx.text)
            .disposed(by: disposeBag)

        model.isAddToCartButtonVisible
            .drive(onNext: { [weak self] isAddToCartButtonVisible in
                self?.addToCartButton.isHidden = !isAddToCartButtonVisible
                self?.countActionsStackView.isHidden = isAddToCartButtonVisible
            })
            .disposed(by: disposeBag)

        addToCartButton.rx.tap
            .map { ProductItemCollectionViewModel.Event.increment }
            .bind(onNext: model.dispatch(event:))
            .disposed(by: disposeBag)

        incrementButton.rx.tap
            .map { ProductItemCollectionViewModel.Event.increment }
            .bind(onNext: model.dispatch(event:))
            .disposed(by: disposeBag)

        decrementButton.rx.tap
            .map { ProductItemCollectionViewModel.Event.decrement }
            .bind(onNext: model.dispatch(event:))
            .disposed(by: disposeBag)
    }
}
