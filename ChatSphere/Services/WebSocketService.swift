//
//  WebSocketService.swift
//  ChatSphere
//
//  Created by Sreeni on 25/04/25.
//

import Foundation
import Combine

class WebSocketService: ObservableObject {
    static let shared = WebSocketService()
    
    @Published var chats: [Chat] = []
    @Published var isOnline: Bool = true

    private var webSocketTask: URLSessionWebSocketTask?
    private let url = URL(string: "wss://s14531.blr1.piesocket.com/v3/1?api_key=viMFjBczudD4dw4D7tU9dYGzrLn5mgpiTsfacEPM")! 

    private var activeChatTitle: String = "Noah"
    private var messageQueue: [String] = []

    private init() {
        connect()
    }

    func connect() {
        webSocketTask = URLSession.shared.webSocketTask(with: url)
        webSocketTask?.resume()
        listen()
    }

    private func listen() {
        webSocketTask?.receive { [weak self] result in
            switch result {
            case .success(let message):
                if case .string(let text) = message {
                    DispatchQueue.main.async {
                        self?.receiveMessage(text)
                    }
                }
            case .failure(let error):
                print("Receive error: \(error)")
            }

            self?.listen()
        }
    }

    func setActiveChat(_ title: String) {
        activeChatTitle = title
        if !chats.contains(where: { $0.title == title }) {
            chats.append(Chat(title: title))
        }
    }
    
    func send(_ text: String) {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let message = Message(id: UUID(), text: text, isFromUser: true, timestamp: Date())
        appendMessage(message, to: activeChatTitle)

        if isOnline {
            sendOverSocket(text: text)
        } else {
            messageQueue.append(text)
        }
    }

    
    private func sendOverSocket(text: String) {
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("Send error: \(error)")
            }
        }
    }

    private func receiveMessage(_ text: String) {
        let message = Message(id: UUID(), text: text, isFromUser: false, timestamp: Date())
        appendMessage(message, to: activeChatTitle)
    }

    private func appendMessage(_ message: Message, to chatTitle: String) {
        if let index = chats.firstIndex(where: { $0.title == chatTitle }) {
            chats[index].messages.append(message)
        } else {
            let newChat = Chat(title: chatTitle, messages: [message])
            chats.append(newChat)
        }
    }

    func messages(for title: String) -> [Message] {
        chats.first(where: { $0.title == title })?.messages ?? []
    }

    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    // MARK: - Offline Handling

    func goOnline() {
        isOnline = true
        flushQueue()
    }

    func goOffline() {
        isOnline = false
    }

    private func flushQueue() {
        for text in messageQueue {
            sendOverSocket(text: text)
        }
        messageQueue.removeAll()
    }
}
