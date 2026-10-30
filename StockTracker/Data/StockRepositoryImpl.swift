//
//  StockRepositoryImpl.swift
//  StockTracker
//
//  Created by Palla Kumar on 30/10/26.
//

import Foundation

final class StockRepositoryImpl: StockRepository {
    var onConnectionStateChange: ((FeedConnectionState) -> Void)?
    var onPriceUpdate: ((StockPriceUpdate) -> Void)?

    private let webSocketService: WebSocketService
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private var pendingUpdates: [String: StockPriceUpdate] = [:]

    init(webSocketService: WebSocketService) {
        self.webSocketService = webSocketService
        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        webSocketService.onConnectionStateChange = { [weak self] state in
            self?.onConnectionStateChange?(state)
        }
        webSocketService.onMessage = { [weak self] data in
            self?.handleEcho(data)
        }
    }

    // MARK: - Start Feed -
    func start() {
        webSocketService.connect()
    }

    // MARK: - Stop Feed -
    func stop() {
        webSocketService.disconnect()
    }

    // MARK: - Create Simulated Update -
    func makeSimulatedUpdate(for stock: Stock) -> StockPriceUpdate {
        let movement = Double.random(in: -0.025...0.025)
        let nextPrice = max(0.01, stock.price * (1 + movement))
        return StockPriceUpdate(
            symbol: stock.symbol,
            price: nextPrice,
            previousPrice: stock.price,
            timestamp: Date()
        )
    }

    // MARK: - Send Simulated Update -
    func sendSimulatedUpdate(_ update: StockPriceUpdate) {
        do {
            let data = try encoder.encode(update)
            pendingUpdates[update.symbol] = update
            Task {
                do {
                    try await webSocketService.send(data)
                } catch {
                    await MainActor.run {
                        self.onConnectionStateChange?(.failed(error.localizedDescription))
                    }
                }
            }
        } catch {
            onConnectionStateChange?(.failed("Could not encode price update."))
        }
    }

    // MARK: - Handle Echo -
    private func handleEcho(_ data: Data) {
        do {
            let update = try decoder.decode(StockPriceUpdate.self, from: data)
            pendingUpdates.removeValue(forKey: update.symbol)
            DispatchQueue.main.async {
                self.onPriceUpdate?(update)
            }
        } catch {
            // Ignore messages that are not valid price-update payloads.
        }
    }
}
