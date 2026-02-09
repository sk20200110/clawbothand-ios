import Foundation
import Combine

// MARK: - NetworkService

final class NetworkService {
    static let shared = NetworkService()
    
    private let baseURL: URL
    private let session: URLSession
    private var webSocketTask: URLSessionWebSocketTask?
    private var cancellables = Set<AnyCancellable>()
    
    // Publishers
    let connectionStatus = CurrentValueSubject<Bool, Never>(false)
    let receivedMessage = PassthroughSubject<Data, Never>()
    
    private init() {
        self.baseURL = URL(string: "http://localhost:3000")!
        
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.timeoutIntervalForResource = 300
        self.session = URLSession(configuration: config)
    }
    
    // MARK: - HTTP Methods
    
    func get<T: Decodable>(_ endpoint: String) async throws -> T {
        let request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        return try await fetch(request)
    }
    
    func post<T: Decodable, B: Encodable>(_ endpoint: String, body: B) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        return try await fetch(request)
    }
    
    private func fetch<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    }
    
    // MARK: - WebSocket
    
    func connect() async throws {
        webSocketTask = session.webSocketTask(with: baseURL.appendingPathComponent("ws"))
        webSocketTask?.resume()
        connectionStatus.send(true)
        receiveWebSocketMessages()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
        connectionStatus.send(false)
    }
    
    private func receiveWebSocketMessages() {
        Task {
            do {
                while let message = try await webSocketTask?.receive() {
                    switch message {
                    case .data(let data):
                        receivedMessage.send(data)
                    case .string(let text):
                        if let data = text.data(using: .utf8) {
                            receivedMessage.send(data)
                        }
                    @unknown default:
                        break
                    }
                }
            } catch {
                connectionStatus.send(false)
            }
        }
    }
    
    func send(_ message: String) {
        webSocketTask?.send(.string(message)) { error in
            if let error = error {
                print("WebSocket send error: \(error)")
            }
        }
    }
}

// MARK: - Errors

enum NetworkError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid server response"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        }
    }
}
