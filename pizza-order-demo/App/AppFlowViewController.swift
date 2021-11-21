//
//  AppFlowViewController.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 16.11.2021.
//

import UIKit

final class AppFlowViewController: UITabBarController {
    private let appModulesFactory: AppModulesFactory
    private var cartList: UIViewController?

    init(appModulesFactory: AppModulesFactory) {
        self.appModulesFactory = appModulesFactory
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let cartList = makeCartListModule()
        self.cartList = cartList
        let viewControllers = [
            makePizzaListModule(),
            makeDrinksListModule(),
            cartList
        ].map { UINavigationController(rootViewController: $0) }
        setViewControllers(viewControllers, animated: false)
        selectedIndex = 0
    }

    private func makePizzaListModule() -> UIViewController {
        let vc = appModulesFactory.makePizzaListModule()
        let image = UIImage(named: "tab_bar_cart")
        vc.tabBarItem = UITabBarItem(title: vc.title, image: image, selectedImage: image)
        return vc

    }
    private func makeDrinksListModule() -> UIViewController {
        let vc = appModulesFactory.makeDrinksListModule()
        let image = UIImage(named: "tab_bar_pizza")
        vc.tabBarItem = UITabBarItem(title: vc.title, image: image, selectedImage: image)
        return vc
    }
    private func makeCartListModule() -> UIViewController {
        let vc = appModulesFactory.makeCartListModule(moduleOutput: self)
        let image = UIImage(named: "tab_bar_bottle")
        vc.tabBarItem = UITabBarItem(title: vc.title, image: image, selectedImage: image)
        return vc
    }
}

extension AppFlowViewController: CartListModuleOutput {
    func openAuthorizationFlow() {
        let authVC = appModulesFactory.makeAuthModule()
        cartList?.present(authVC, animated: true, completion: nil)
    }
}
