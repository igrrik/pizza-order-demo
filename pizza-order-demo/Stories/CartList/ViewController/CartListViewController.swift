//
//  CartListViewController.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 21.11.2021.
//

import UIKit

final class CartListViewController: UIViewController, CartListViewInput {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var purchaseContainer: UIView!
    @IBOutlet var purchaseButton: UIButton!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var priceBeforeDiscount: UILabel!

    var viewOutput: CartListViewOutput?
    private var dataSource = [CartListTableViewCellModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart"
        addShadowToPurchaseContainer()
        configureTableView()

        viewOutput?.viewDidLoad()
    }

    @IBAction func didTapPurchaseButton() {
        viewOutput?.didTapPurchaseButton()
    }

    func updatePrice(_ price: CartListModulePrice) {
        switch price {
        case let .plain(value):
            priceLabel.text = value.priceString
            priceBeforeDiscount.isHidden = true
        case let .discount(newPrice, oldPrice):
            priceLabel.text = newPrice.priceString
            priceBeforeDiscount.attributedText = .makeDiscountString(from: oldPrice)
            priceBeforeDiscount.isHidden = false
        }
    }

    func updatePurchaseButton(isActive: Bool) {
        purchaseButton.isEnabled = isActive
    }

    func updateDataSource(_ dataSource: [CartListTableViewCellModel]) {
        self.dataSource = dataSource
        tableView.reloadData()
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 160
        tableView.register(cellClass: CartListTableViewCell.self)
        var insets = tableView.contentInset
        insets.bottom = purchaseContainer.bounds.height
        tableView.contentInset = insets
    }

    private func addShadowToPurchaseContainer() {
        purchaseContainer.layer.shadowColor = UIColor.gray.cgColor
        purchaseContainer.layer.shadowOpacity = 1
        purchaseContainer.layer.shadowRadius = 5
        let rect = CGRect(x: 0, y: 0, width: view.bounds.width, height: 1)
        purchaseContainer.layer.shadowPath = UIBezierPath(rect: rect).cgPath
        
    }
}

extension CartListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = String(describing: CartListTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! CartListTableViewCell
        cell.configure(with: dataSource[indexPath.row])
        return cell
    }
}

extension CartListViewController: UITableViewDelegate {}

private extension NSAttributedString {
    static func makeDiscountString(from price: Double) -> NSAttributedString {
        let strokeEffect: [NSAttributedString.Key : Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.red,
            .font: UIFont.preferredFont(forTextStyle: .subheadline)
        ]
        return NSAttributedString(string: price.priceString, attributes: strokeEffect)
    }
}

private extension Double {
    var priceString: String { "\(self) $"}
}
