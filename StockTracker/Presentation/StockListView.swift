

//
//  StockListView.swift
//  StockTracker
//
//  Created by Palla Kumar on 30/10/26.
//

import SwiftUI

struct StockListView: View {
    @ObservedObject var store: StockStore

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                connectionBanner
                sortPicker
                List(store.sortedStocks) { stock in
                    NavigationLink(destination: StockDetailView(symbol: stock.symbol, store: store)) {
                        StockRowView(stock: stock)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Market Watch")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        store.toggleFeed()
                    } label: {
                        Label(
                            store.connectionState == .connected || store.connectionState == .connecting ? "Stop" : "Start",
                            systemImage: store.connectionState == .connected || store.connectionState == .connecting ? "stop.fill" : "play.fill"
                        )
                    }
                    .accessibilityIdentifier("feedToggleButton")
                }
            }
        }
    }

    private var connectionBanner: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(store.connectionState.title)
                .font(.subheadline.weight(.medium))
            Spacer()
            if let lastUpdate = store.lastUpdate {
                Text("Updated \(lastUpdate.formatted(date: .omitted, time: .shortened))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Simulated feed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(Color(UIColor.secondarySystemBackground))
    }

    private var sortPicker: some View {
        Picker("Sort by", selection: $store.sortOption) {
            ForEach(StockSortOption.allCases) { option in
                Text(option.rawValue).tag(option)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var statusColor: Color {
        switch store.connectionState {
        case .connected: return .green
        case .connecting: return .orange
        case .disconnected, .failed: return .red
        }
    }
}

private struct StockRowView: View {
    let stock: Stock

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(stock.symbol)
                    .font(.headline)
                Text(stock.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer(minLength: 8)
            VStack(alignment: .trailing, spacing: 4) {
                Text(stock.price, format: .currency(code: "USD"))
                    .font(.headline.monospacedDigit())
                HStack(spacing: 4) {
                    Image(systemName: stock.isPositive ? "arrow.up.right" : "arrow.down.right")
                    Text("\(stock.priceChange >= 0 ? "+" : "")\(stock.priceChange, specifier: "%.2f") (\(stock.priceChangePercentage, specifier: "%.2f")%)")
                }
                .font(.caption.monospacedDigit())
                .foregroundColor(stock.isPositive ? .green : .red)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Preview -
struct StockListView_Previews: PreviewProvider {
    static var previews: some View {
        StockListView(store: StockStore(repository: StockRepositoryImpl(webSocketService: WebSocketService())))
    }
}
