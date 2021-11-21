//
//  CartListTableViewCell.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 21.11.2021.
//

import UIKit

final class CartListTableViewCell: UITableViewCell {

    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var productImageView: UIImageView!

    private var model: CartListTableViewCellModel?

    override func prepareForReuse() {
        super.prepareForReuse()
        model = nil
    }

    func configure(with model: CartListTableViewCellModel) {
        priceLabel.text = model.price
        titleLabel.text = model.title
        countLabel.text = model.count
        productImageView.image = model.productImage
        self.model = model
    }

    @IBAction func didTapIncrementButton() {
        model?.onTapIncrement?()
    }

    @IBAction func didTapDecrementButton() {
        model?.onTapDecrement?()
    }
}

struct CartListTableViewCellModel {
    let price: String
    let title: String
    let count: String
    let productImage: UIImage
    var onTapIncrement: (() -> Void)?
    var onTapDecrement: (() -> Void)?
}
