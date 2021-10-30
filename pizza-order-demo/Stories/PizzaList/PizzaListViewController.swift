//
//  PizzaListViewController.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 29.10.2021.
//

import UIKit
import RxCocoa
import RxSwift

final class PizzaListViewController: UIViewController {
    private let collectionViewInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    private lazy var flowLayout = UICollectionViewFlowLayout()
    private lazy var collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: flowLayout)
    private lazy var proceedToPaymentButton = UIButton(configuration: .filled())
    private var proceedToPaymentButtonBottomConstraint: NSLayoutConstraint?
    private let viewModel: PizzaListViewModel
    private var dataSource = [PizzaItemCollectionViewModel]()
    private let diposeBag = DisposeBag()

    init(viewModel: PizzaListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()

        viewModel.dataSource
            .drive(onNext: { [weak self] items in
                self?.dataSource = items
                self?.collectionView.reloadData()
            })
            .disposed(by: diposeBag)

        
    }

    func configureUI() {
        title = "Photos"
        view.backgroundColor = .white
        configureCollectionView()
    }

    func configureCollectionView() {
        collectionView.register(cellClass: PizzaItemCollectionViewCell.self)
        collectionView.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        flowLayout.sectionInset = collectionViewInsets
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func configureProceedToPaymentButton() {
        view.addSubview(proceedToPaymentButton)
        proceedToPaymentButton.translatesAutoresizingMaskIntoConstraints = false
        proceedToPaymentButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        proceedToPaymentButtonBottomConstraint = proceedToPaymentButton
            .bottomAnchor
            .constraint(equalTo: view.bottomAnchor, constant: -32)
            .isActive = true
    }
}

extension PizzaListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let identifier = String(describing: PizzaItemCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        guard let pizzaCell = cell as? PizzaItemCollectionViewCell else {
            fatalError("Failed to deque cell")
        }
        let model = dataSource[indexPath.item]
        pizzaCell.configure(with: model)
        return pizzaCell
    }
}

extension PizzaListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let itemsPerRow: CGFloat = 2
        let paddingSpace = collectionViewInsets.left * (itemsPerRow + 1)
        let availableWidth = collectionView.frame.width - paddingSpace
        let widthPerItem = (availableWidth / itemsPerRow).rounded(.down)

        return CGSize(width: widthPerItem, height: widthPerItem)
    }
}
