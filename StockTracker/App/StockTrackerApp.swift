//
//  StockTrackerApp.swift
//  StockTracker
//
//  Created by Palla Kumar on 30/10/26.
//

import SwiftUI

@main
struct StockTrackerApp: App {
    @StateObject private var store: StockStore

    init() {
        let repository = StockRepositoryImpl(
            webSocketService: WebSocketService()
        )
        _store = StateObject(wrappedValue: StockStore(repository: repository))
    }

    var body: some Scene {
        WindowGroup {
            StockListView(store: store)
        }
    }
}
