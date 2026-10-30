//
//  WebSocketService.swift
//  StockTracker
//
//  Created by Palla Kumar on 30/10/26.
//


import Foundation

final class WebSocketService {

    var onConnectionStateChange: ((FeedConnectionState) -> Void)?
    var onMessage: ((Data) -> Void)?

    private let url: URL
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    private var receiveTask: Task<Void, Never>?

    init(url: URL = URL(string: "wss://ws.postman-echo.com/raw")!) {
        self.url = url
    }

    // MARK: - Start Connection -

    func connect() {
        guard webSocketTask == nil else { return }

        onConnectionStateChange?(.connecting)

        let newSession = URLSession(configuration: .default)
        let newTask = newSession.webSocketTask(with: url)

        session = newSession
        webSocketTask = newTask

        newTask.resume()

        onConnectionStateChange?(.connected)

        startReceiveLoop(for: newTask)
    }

    // MARK: - Send Message -

    func send(_ data: Data) async throws {
        guard let activeTask = webSocketTask else {
            throw WebSocketError.notConnected
        }

        try await activeTask.send(.data(data))
    }

    // MARK: - Receive Messages -

    private func startReceiveLoop(for activeTask: URLSessionWebSocketTask) {
        receiveTask?.cancel()

        receiveTask = Task { [weak self] in

            guard let strongSelf = self else { return }

            while !Task.isCancelled {
                do {
                    let message = try await activeTask.receive()

                    let receivedData: Data

                    switch message {
                    case .data(let data):
                        receivedData = data

                    case .string(let string):
                        guard let data = string.data(using: .utf8) else {
                            continue
                        }
                        receivedData = data

                    @unknown default:
                        continue
                    }

                    DispatchQueue.main.async { [weak strongSelf] in
                        strongSelf?.onMessage?(receivedData)
                    }

                } catch {
                    if Task.isCancelled {
                        return
                    }

                    DispatchQueue.main.async { [weak strongSelf] in
                        strongSelf?.onConnectionStateChange?(
                            .failed(error.localizedDescription)
                        )
                    }

                    return
                }
            }
        }
    }

    // MARK: - Disconnect -

    func disconnect() {
        receiveTask?.cancel()
        receiveTask = nil

        webSocketTask?.cancel(
            with: .normalClosure,
            reason: nil
        )

        webSocketTask = nil

        session?.invalidateAndCancel()
        session = nil

        onConnectionStateChange?(.disconnected)
    }
}

// MARK: - WebSocket Error -

enum WebSocketError: LocalizedError {

    case notConnected

    var errorDescription: String? {
        switch self {
        case .notConnected:
            return "WebSocket is not connected."
        }
    }
}
