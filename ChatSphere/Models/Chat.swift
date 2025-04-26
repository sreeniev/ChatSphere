//
//  Chat.swift
//  ChatSphere
//
//  Created by Sreeni on 25/04/25.
//

import Foundation

struct Chat: Identifiable {
    let id = UUID()
    let title: String // Chatbot name like "Noah"
    var messages: [Message] = []

    var lastMessagePreview: String {
        messages.last?.text ?? "No messages yet"
    }
}



