//
//  AppFlowControllerViewController.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 16.11.2021.
//

import UIKit

final class AppFlowControllerViewController: UITabBarController {
    private let appModulesFactory: AppModulesFactory

    init(appModulesFactory: AppModulesFactory) {
        self.appModulesFactory = appModulesFactory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let viewControllers = [
            appModulesFactory.makePizzaListModule(),
            appModulesFactory.makeDrinksListModule(),
            appModulesFactory.makeCartListModule()
        ].map { UINavigationController(rootViewController: $0) }
        setViewControllers(viewControllers, animated: false)
        selectedIndex = 0
    }
}
