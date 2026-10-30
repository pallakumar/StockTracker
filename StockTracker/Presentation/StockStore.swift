
//
//  StockStore.swift
//  StockTracker
//
//  Created by Palla Kumar on 30/10/26.
//


import Foundation
import SwiftUI

enum StockSortOption: String, CaseIterable, Identifiable {
    case price = "Price"
    case priceChange = "Price Change"

    var id: String { rawValue }
}

@MainActor
final class StockStore: ObservableObject {
    @Published private(set) var stocks: [Stock] = StockStore.seedStocks
    @Published private(set) var connectionState: FeedConnectionState = .disconnected
    @Published private(set) var lastUpdate: Date?
    @Published var sortOption: StockSortOption = .price

    private let repository: StockRepository
    private var feedTask: Task<Void, Never>?

    init(repository: StockRepository) {
        self.repository = repository
        repository.onConnectionStateChange = { [weak self] state in
            Task { @MainActor [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.connectionState = state
            }
        }
        repository.onPriceUpdate = { [weak self] update in
            Task { @MainActor [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.apply(update)
            }
        }
    }

    var sortedStocks: [Stock] {
        switch sortOption {
        case .price:
            return stocks.sorted { $0.price > $1.price }
        case .priceChange:
            return stocks.sorted { abs($0.priceChangePercentage) > abs($1.priceChangePercentage) }
        }
    }

    func stock(for symbol: String) -> Stock? {
        stocks.first { $0.symbol == symbol }
    }

    // MARK: - Toggle Feed -
    func toggleFeed() {
        if connectionState == .connected || connectionState == .connecting {
            stopFeed()
        } else {
            startFeed()
        }
    }

    // MARK: - Start Feed -
    func startFeed() {
        guard feedTask == nil else { return }
        repository.start()
        feedTask = Task { [weak self] in
            guard let strongSelf = self else { return }
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                guard !Task.isCancelled else { break }
                guard strongSelf.connectionState == .connected else { continue }
                for stock in strongSelf.stocks.shuffled().prefix(5) {
                    let update = strongSelf.repository.makeSimulatedUpdate(for: stock)
                    strongSelf.repository.sendSimulatedUpdate(update)
                }
            }
        }
    }

    // MARK: - Stop Feed -
    func stopFeed() {
        feedTask?.cancel()
        feedTask = nil
        repository.stop()
    }

    // MARK: - Apply Update -
    func apply(_ update: StockPriceUpdate) {
        guard let index = stocks.firstIndex(where: { $0.symbol == update.symbol }) else { return }
        stocks[index].apply(price: update.price)
        lastUpdate = update.timestamp
    }

    // MARK: - Seed Stocks -
    static let seedStocks: [Stock] = [
        Stock(symbol: "AAPL", name: "Apple Inc.", price: 231.50, previousPrice: 229.90),
        Stock(symbol: "GOOG", name: "Alphabet Inc.", price: 176.20, previousPrice: 177.10),
        Stock(symbol: "TSLA", name: "Tesla, Inc.", price: 248.50, previousPrice: 244.30),
        Stock(symbol: "AMZN", name: "Amazon.com, Inc.", price: 187.30, previousPrice: 188.20),
        Stock(symbol: "MSFT", name: "Microsoft Corporation", price: 427.80, previousPrice: 425.10),
        Stock(symbol: "NVDA", name: "NVIDIA Corporation", price: 138.85, previousPrice: 136.40),
        Stock(symbol: "META", name: "Meta Platforms, Inc.", price: 595.20, previousPrice: 590.50),
        Stock(symbol: "NFLX", name: "Netflix, Inc.", price: 754.40, previousPrice: 748.00),
        Stock(symbol: "ORCL", name: "Oracle Corporation", price: 172.10, previousPrice: 173.20),
        Stock(symbol: "INTC", name: "Intel Corporation", price: 24.50, previousPrice: 24.90),
        Stock(symbol: "AMD", name: "Advanced Micro Devices", price: 164.30, previousPrice: 161.80),
        Stock(symbol: "CRM", name: "Salesforce, Inc.", price: 292.60, previousPrice: 294.10),
        Stock(symbol: "ADBE", name: "Adobe Inc.", price: 487.20, previousPrice: 482.60),
        Stock(symbol: "QCOM", name: "Qualcomm Incorporated", price: 168.70, previousPrice: 167.40),
        Stock(symbol: "AVGO", name: "Broadcom Inc.", price: 181.60, previousPrice: 179.20),
        Stock(symbol: "IBM", name: "International Business Machines", price: 224.10, previousPrice: 225.30),
        Stock(symbol: "DIS", name: "The Walt Disney Company", price: 112.80, previousPrice: 111.40),
        Stock(symbol: "UBER", name: "Uber Technologies, Inc.", price: 78.30, previousPrice: 77.10),
        Stock(symbol: "SHOP", name: "Shopify Inc.", price: 112.40, previousPrice: 114.00),
        Stock(symbol: "PYPL", name: "PayPal Holdings, Inc.", price: 80.50, previousPrice: 81.30),
        Stock(symbol: "COST", name: "Costco Wholesale Corporation", price: 902.20, previousPrice: 898.70),
        Stock(symbol: "WMT", name: "Walmart Inc.", price: 82.70, previousPrice: 82.10),
        Stock(symbol: "JPM", name: "JPMorgan Chase & Co.", price: 244.60, previousPrice: 242.80),
        Stock(symbol: "V", name: "Visa Inc.", price: 343.20, previousPrice: 340.50),
        Stock(symbol: "KO", name: "The Coca-Cola Company", price: 70.10, previousPrice: 70.60)
    ]
}
