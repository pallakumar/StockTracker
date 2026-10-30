//
//  Stock.swift
//  StockTracker
//
//  Created by Palla Kumar on 30/10/26.
//

import Foundation

struct Stock: Identifiable, Equatable {
    let symbol: String
    let name: String
    var price: Double
    var previousPrice: Double

    var id: String { symbol }

    var priceChange: Double {
        price - previousPrice
    }

    var priceChangePercentage: Double {
        guard previousPrice != 0 else { return 0 }
        return (priceChange / previousPrice) * 100
    }

    var isPositive: Bool {
        priceChange >= 0
    }

    // MARK: - Apply Price Update -
    mutating func apply(price newPrice: Double) {
        previousPrice = price
        price = newPrice
    }
}

struct StockPriceUpdate: Codable, Equatable {
    let symbol: String
    let price: Double
    let previousPrice: Double
    let timestamp: Date
}
