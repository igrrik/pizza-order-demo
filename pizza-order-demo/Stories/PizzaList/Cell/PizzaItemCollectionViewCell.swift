//
//  PizzaItemCollectionViewCell.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 29.10.2021.
//

import UIKit
import RxFeedback
import RxSwift
import RxCocoa

final class PizzaItemCollectionViewCell: UICollectionViewCell {
    @IBOutlet var pizzaImageView: UIImageView!
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

    func configure(with model: PizzaItemCollectionViewModel) {
        model.pizzaImage
            .drive(pizzaImageView.rx.image)
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
            .debug()
            .map { PizzaItemCollectionViewModel.Event.increment }
            .bind(onNext: model.dispatch(event:))
            .disposed(by: disposeBag)

        incrementButton.rx.tap
            .debug()
            .map { PizzaItemCollectionViewModel.Event.increment }
            .bind(onNext: model.dispatch(event:))
            .disposed(by: disposeBag)

        decrementButton.rx.tap
            .debug()
            .map { PizzaItemCollectionViewModel.Event.decrement }
            .bind(onNext: model.dispatch(event:))
            .disposed(by: disposeBag)

//        let decrementEvents = decrementButton.rx.tap
//            .map { PizzaItemCollectionViewModel.Event.decrement }
//        let incrementEvents = addToCartButton.rx.tap
//            .debug()
//            .concat(incrementButton.rx.tap)
//            .map { PizzaItemCollectionViewModel.Event.increment }
//
//        decrementEvents.concat(incrementEvents)
//            .bind(onNext: model.dispatch(event:))
//            .disposed(by: disposeBag)
    }
}
