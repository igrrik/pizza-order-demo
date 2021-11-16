//
//  ProductListViewController.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 29.10.2021.
//

import UIKit
import RxCocoa
import RxSwift

final class ProductListViewController: UIViewController {
    private let collectionViewInsets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    private lazy var flowLayout = UICollectionViewFlowLayout()
    private lazy var collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: flowLayout)
    private let viewModel: ProductListViewModel
    private var dataSource = [ProductItemCollectionViewModel]()
    private let diposeBag = DisposeBag()

    init(viewModel: ProductListViewModel) {
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

        viewModel.loadProducts()
    }

    func configureUI() {
        title = "Products"
        view.backgroundColor = .white
        configureCollectionView()
    }

    func configureCollectionView() {
        collectionView.register(cellClass: ProductItemCollectionViewCell.self)
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
}

extension ProductListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let identifier = String(describing: ProductItemCollectionViewCell.self)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        guard let productCell = cell as? ProductItemCollectionViewCell else {
            fatalError("Failed to deque cell")
        }
        let model = dataSource[indexPath.item]
        productCell.configure(with: model)
        return productCell
    }
}

extension ProductListViewController: UICollectionViewDelegateFlowLayout {
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
