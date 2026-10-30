
//
//  StockDetailView.swift
//  StockTracker
//
//  Created by Palla Kumar on 30/10/26.
//


import SwiftUI

// MARK: - Stock Detail View -

struct StockDetailView: View {

    let symbol: String

    @ObservedObject var store: StockStore

    // MARK: - Selected Stock -

    private var stock: Stock? {
        return store.stock(for: symbol)
    }

    // MARK: - Body -

    var body: some View {

        Group {

            if let stock = stock {

                ScrollView {

                    VStack(alignment: .leading, spacing: 20) {

                        VStack(alignment: .leading, spacing: 8) {

                            Text(stock.symbol)
                                .font(.largeTitle)
                                .bold()

                            Text(stock.name)
                                .font(.title3)
                                .foregroundColor(.secondary)

                            Text(stock.price, format: .currency(code: "USD"))
                                .font(.system(
                                    size: 36,
                                    weight: .bold,
                                    design: .rounded
                                ))

                            HStack(spacing: 6) {

                                Image(
                                    systemName: stock.isPositive
                                    ? "arrow.up.right"
                                    : "arrow.down.right"
                                )

                                Text(
                                    "\(stock.priceChange >= 0 ? "+" : "")\(stock.priceChange, specifier: "%.2f") (\(stock.priceChangePercentage, specifier: "%.2f")%)"
                                )
                            }
                            .font(.headline)
                            .foregroundColor(
                                stock.isPositive ? .green : .red
                            )
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(
                            Color(UIColor.secondarySystemBackground)
                        )
                        .cornerRadius(18)

                        // MARK: - Stock Description -

                        VStack(alignment: .leading, spacing: 8) {

                            Text("About \(stock.name)")
                                .font(.headline)

                            Text(description(for: stock.symbol))
                                .font(.body)
                                .foregroundColor(.secondary)
                        }

                        // MARK: - Connection Status -

                        Label(
                            "Feed: \(store.connectionState.title)",
                            systemImage: "antenna.radiowaves.left.and.right"
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                        // MARK: - Feed Control -

                        Button(action: {
                            store.toggleFeed()
                        }) {

                            Label(
                                store.connectionState == .connected ||
                                store.connectionState == .connecting
                                ? "Stop Price Feed"
                                : "Start Price Feed",

                                systemImage:
                                store.connectionState == .connected ||
                                store.connectionState == .connecting
                                ? "stop.fill"
                                : "play.fill"
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(
                            BorderlessButtonStyle()
                        )
                    }
                    .padding()
                }

            } else {

                VStack(spacing: 12) {

                    Image(systemName: "chart.line.downtrend.xyaxis")
                        .font(.largeTitle)

                    Text("Stock not found")
                        .font(.headline)
                }
            }
        }
        .navigationTitle(symbol)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Stock Description -

    private func description(for symbol: String) -> String {

        switch symbol {

        case "AAPL":
            return "Apple designs and sells consumer electronics, software, and digital services."

        case "GOOG":
            return "Alphabet is a technology company with businesses spanning search, advertising, cloud, and AI."

        case "TSLA":
            return "Tesla develops electric vehicles, energy storage, and related software."

        case "AMZN":
            return "Amazon operates e-commerce, cloud computing, and digital services businesses."

        case "MSFT":
            return "Microsoft develops software, cloud services, productivity tools, and enterprise technology."

        case "NVDA":
            return "NVIDIA develops GPUs, accelerated computing platforms, and AI infrastructure."

        default:
            return "\(stockName(symbol)) is a publicly traded company. Prices shown in this assessment are simulated."
        }
    }

    // MARK: - Stock Name -

    private func stockName(_ symbol: String) -> String {

        return store.stock(for: symbol)?.name ?? symbol
    }
}
