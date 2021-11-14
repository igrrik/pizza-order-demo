//
//  Pizza.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 30.10.2021.
//

import UIKit

struct Pizza: Hashable {
    let name: String
    let price: Int
    let image: UIImage
}

extension Pizza {
    static var allPizzas: [Pizza] = [.margarita, .bbq, .fourSeasons, .quattroFormagge]

    static let margarita = Pizza(name: "Margarita", price: 350, image: UIImage(named: "margarita")!)
    static let bbq = Pizza(name: "BBQ", price: 699, image: UIImage(named: "barbeque")!)
    static let fourSeasons = Pizza(name: "Four seasons", price: 545, image: UIImage(named: "four_seasons")!)
    static let quattroFormagge = Pizza(name: "Quattro Formagge", price: 430, image: UIImage(named: "quattro_formagge")!)
}
