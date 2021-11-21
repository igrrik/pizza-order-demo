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

    func updatePrice(_ price: String) {
        priceLabel.text = price
    }

    func updatePurchaseButton(isActive: Bool) {
        purchaseButton.isEnabled = isActive
    }

    func updateDataSource(_ dataSource: [CartListTableViewCellModel]) {
        self.dataSource = dataSource
        tableView.reloadData()
    }

    func displayError(_ error: Error) {
        let controller = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(controller, animated: true, completion: nil)
    }

    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 160
        tableView.register(cellClass: CartListTableViewCell.self)
    }

    private func addShadowToPurchaseContainer() {
        purchaseContainer.layer.shadowColor = UIColor.black.cgColor
        purchaseContainer.layer.shadowOpacity = 1
        purchaseContainer.layer.shadowOffset = .zero
        purchaseContainer.layer.shadowRadius = 10
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