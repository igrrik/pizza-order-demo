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
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var decrementButton: UIButton!
    @IBOutlet var incrementButton: UIButton!

    private var disposeBag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = .init()
    }

    func configure(with model: PizzaItemCollectionViewModel) {
        model.state
            .map { $0.pizzaImage }
            .drive(pizzaImageView.rx.image)
            .disposed(by: disposeBag)

        model.state
            .map { String(describing: $0.count) }
            .drive(countLabel.rx.text)
            .disposed(by: disposeBag)

        model.state
            .map { !$0.isAddToCartButtonVisible }
            .drive(addToCartButton.rx.isHidden).disposed(by: disposeBag)

        decrementButton.rx.tap
            .map { PizzaItemCollectionViewModel.Event.decrement }
            .bind(to: model.dispatcher)
            .disposed(by: disposeBag)

        addToCartButton.rx.tap
            .map { PizzaItemCollectionViewModel.Event.increment }
            .bind(to: model.dispatcher)
            .disposed(by: disposeBag)

        incrementButton.rx.tap
            .map { PizzaItemCollectionViewModel.Event.increment }
            .bind(to: model.dispatcher)
            .disposed(by: disposeBag)
    }
}

final class PizzaItemCollectionViewModel {
    struct State: Equatable {
        var count: Int = 0
        var isAddToCartButtonVisible: Bool { count == 0 }
        var pizzaImage: UIImage
    }

    enum Event {
        case increment
        case decrement
    }

    let state: Driver<State>
    let dispatcher: PublishRelay<Event>

    init(pizzaImage: UIImage) {
        let dispatcher = PublishRelay<Event>()
        self.state = Driver.system(
            initialState: State(pizzaImage: pizzaImage),
            reduce: { (state: State, event: Event) in
                var state = state
                switch event {
                case .decrement:
                    state.count -= 1
                case .increment:
                    state.count += 1
                }
                return state
            },
            feedback: [{ _ in dispatcher.asSignal() }]
        )
        self.dispatcher = dispatcher
    }
}
