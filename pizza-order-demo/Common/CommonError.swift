//
//  CommonError.swift
//  pizza-order-demo
//
//  Created by Igor Kokoev on 21.11.2021.
//

import Foundation

struct CommonError: LocalizedError {
    let text: String
    var errorDescription: String? { text }
}
