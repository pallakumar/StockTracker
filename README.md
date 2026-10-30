# StockTracker – Real-Time Stock Price Tracker

StockTracker is a SwiftUI-based iOS application developed as part of the MultiBank Senior iOS Engineer assessment.

The application provides a watchlist of 25 stocks, displays their prices and price movements, supports sorting, and allows users to view individual stock details. It also demonstrates WebSocket communication using simulated stock-price updates.

> Note: The application uses sample stock prices and randomly generated price movements. It connects to the Postman Echo WebSocket endpoint to demonstrate sending and receiving messages. It does not fetch live stock-market data.

## Features

- Displays 25 stocks with their ticker symbols, company names, prices, and price changes.
- Sorts stocks by price or percentage price change.
- Provides a separate detail screen for each stock.
- Keeps stock data synchronized between the list and detail screens using a shared store.
- Allows users to start and stop the simulated price feed.
- Displays connection status, including Disconnected, Connecting, Connected, and Connection error.
- Sends simulated price updates as JSON messages through a WebSocket connection and processes the echoed responses.

## Technologies Used

- Swift 5.5
- SwiftUI
- UIKit / Foundation
- URLSessionWebSocketTask
- Swift Concurrency (async/await and Task)
- XCTest

The source code is designed for compatibility with Xcode 13.2.1 and Swift 5.5. The recommended minimum deployment target is iOS 15.0.

## Project Architecture

The project follows a separation of concerns across the Domain, Data, and Presentation layers.

```text
StockTracker/
├── App/
│   └── StockTrackerApp.swift
├── Domain/
│   ├── Models/
│   │   └── Stock.swift
│   └── Repositories/
│       └── StockRepository.swift
├── Data/
│   ├── StockRepositoryImpl.swift
│   └── WebSocketService.swift
├── Presentation/
│   ├── StockStore.swift
│   ├── StockListView.swift
│   └── StockDetailView.swift
└── Tests/
    └── StockTrackerTests.swift
```

### Domain Layer

The Domain layer contains the core stock models and repository contract.

- `Stock.swift` defines the stock model and price-update data.
- `StockRepository.swift` defines the operations required to manage the stock feed, receive price updates, and observe connection-state changes.
- `FeedConnectionState` represents the different WebSocket connection states.

### Data Layer

The Data layer handles WebSocket communication and stock-price updates.

- `WebSocketService.swift` manages the WebSocket lifecycle using `URLSessionWebSocketTask`, including connecting, sending messages, receiving responses, and disconnecting.
- `StockRepositoryImpl.swift` implements the repository contract. It generates simulated price movements, converts updates into JSON, sends them through the WebSocket, and processes the echoed responses.

### Presentation Layer

The Presentation layer manages the application state and user interface.

- `StockStore.swift` acts as the shared `ObservableObject`. It maintains the stock collection, sorting selection, connection state, and periodic update task.
- `StockListView.swift` displays the watchlist, sorting options, connection status, and feed controls.
- `StockDetailView.swift` displays the selected stock's information and observes changes through the shared store.

This structure keeps the UI separate from networking and business logic, making the application easier to maintain and extend.

## WebSocket Implementation

The application uses the following WebSocket endpoint:

`wss://ws.postman-echo.com/raw`

The price-update flow works as follows:

1. The user starts the feed from the Market Watch screen.
2. `StockStore` asks the repository to establish a WebSocket connection.
3. `WebSocketService` initiates the connection and uses a ping/pong response to confirm connectivity.
4. Once connected, the application periodically generates simulated price movements for selected stocks.
5. The repository encodes each update into JSON and sends it through the WebSocket.
6. Postman Echo returns the message to the application.
7. The repository decodes the response and forwards the update to `StockStore`.
8. The shared store updates the corresponding stock, and SwiftUI refreshes the affected views.

When the user stops the feed, the periodic update task is cancelled and the WebSocket connection is closed.

Connection and communication failures are reflected in the connection status.

Important: Postman Echo is used only to demonstrate WebSocket communication. It does not provide stock quotes or financial market data. All price movements are simulated within the application.

## Requirements

- macOS with Xcode 13.2.1 or later
- iOS 15.0 or later
- iOS Simulator or a compatible physical device
- Internet connection for the WebSocket demonstration

## How to Run

1. Clone or download this repository.
2. Open `StockTracker.xcodeproj` in Xcode.
3. Select the `StockTracker` scheme.
4. Choose an iOS 15.0 or later simulator, such as iPhone 13.
5. Build and run the application using Product → Run or `Command + R`.
6. On the Market Watch screen, tap the Play button to start the feed.
7. Tap the Stop button to stop receiving updates.
8. Select any stock to open its detail screen.
9. Use the sorting control to switch between Price and Price Change.

### XCTest Configuration

If Xcode reports `No such module 'XCTest'`, check the following:

- `StockTrackerTests.swift` must belong to the `StockTrackerTests` unit test target.
- It must not be included in the main `StockTracker` application target.
- The unit test target should use `StockTracker` as its host application.

## Unit Tests

The project includes five unit-test cases covering:

1. Sorting stocks by price in descending order.
2. Sorting stocks by absolute percentage price change.
3. Applying a price update while retaining the previous price.
4. Ignoring updates for unknown stock symbols.
5. Encoding and decoding price updates using JSON.

To execute the tests:

1. Select the `StockTracker` scheme in Xcode.
2. Choose Product → Test, or press `Command + U`.
3. Review the results in Xcode's Test Navigator.

The tests are included in the project. Their successful execution should be confirmed in Xcode before submission.

## Future Improvements

For a production-ready stock-tracking application, the simulated price generator and echo endpoint could be replaced with a licensed financial market-data provider.

Additional improvements could include:

- Automatic reconnection with retry and backoff handling.
- Authentication and secure API communication.
- Improved error handling and message validation.
- Logging and monitoring.
- Additional integration and UI tests.

---

Developed as part of the MultiBank Senior iOS Engineer assessment.
