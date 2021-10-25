//
//  UIViewController+ErrorRepresentable.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 26.10.2021.
//

import UIKit

extension UIViewController {
    func present(error: String, animated: Bool = true, completion: (() -> Void)? = nil) {
        let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(controller, animated: animated, completion: completion)
    }
}
