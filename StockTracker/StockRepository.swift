//
//  StockRepository.swift
//  StockTracker
//
//  Created by Palla Kumar on 30/10/26.
//

import Foundation

enum FeedConnectionState: Equatable {
    case disconnected
    case connecting
    case connected
    case failed(String)

    var title: String {
        switch self {
        case .disconnected: return "Disconnected"
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .failed: return "Connection error"
        }
    }
}

protocol StockRepository: AnyObject {
    var onConnectionStateChange: ((FeedConnectionState) -> Void)? { get set }
    var onPriceUpdate: ((StockPriceUpdate) -> Void)? { get set }

    func start()
    func stop()
    func sendSimulatedUpdate(_ update: StockPriceUpdate)
    func makeSimulatedUpdate(for stock: Stock) -> StockPriceUpdate
}
