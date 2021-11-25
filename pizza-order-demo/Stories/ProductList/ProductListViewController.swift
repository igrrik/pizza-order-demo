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
    private lazy var loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    private let viewModel: ProductListViewModel
    private let diposeBag = DisposeBag()
    private var dataSource = [ProductItemCollectionViewModel]()

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
        configureBindings()

        viewModel.loadProducts()
    }

    private func configureUI() {
        view.backgroundColor = .white
        configureCollectionView()
        configureLoadingIndicator()
    }

    private func configureLoadingIndicator() {
        view.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func configureCollectionView() {
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

    private func configureBindings() {
        viewModel.dataSource
            .drive(onNext: { [weak self] items in
                self?.dataSource = items
                self?.collectionView.reloadData()
            })
            .disposed(by: diposeBag)

        viewModel.isLoadingIndicatorVisible
            .drive(loadingIndicator.rx.isAnimating)
            .disposed(by: diposeBag)
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
