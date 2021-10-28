//
//  UICollectionView+CellRegistration.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 29.10.2021.
//

import UIKit

extension UICollectionView {
    func register<T: UICollectionViewCell>(cellClass: T.Type) {
        let identifier = String(describing: cellClass)
        let nib = UINib(nibName: identifier, bundle: Bundle(for: cellClass))
        register(nib, forCellWithReuseIdentifier: identifier)
    }
}
