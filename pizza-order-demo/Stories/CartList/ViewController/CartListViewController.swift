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
