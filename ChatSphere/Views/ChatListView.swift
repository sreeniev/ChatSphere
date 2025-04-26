//
//  ChatListView.swift
//  ChatSphere
//
//  Created by Sreeni on 25/04/25.
//

import SwiftUI

struct ChatListView: View {
    @StateObject private var socket = WebSocketService.shared
    @State private var selectedChatTitle: String = "Noah"
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool

    let chatbotTitles = ["Noah", "Ted", "Samantha"]

    var body: some View {
        VStack(spacing: 0) {
            // Header with bot tabs & toggle
            HStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(chatbotTitles, id: \.self) { title in
                            Button(action: {
                                selectedChatTitle = title
                                socket.setActiveChat(title)
                            }) {
                                Text(title)
                                    .fontWeight(.medium)
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 14)
                                    .background(selectedChatTitle == title ? Color.blue.opacity(0.2) : Color.clear)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                Spacer()

                Button(action: {
                    if socket.isOnline {
                        socket.goOffline()
                    } else {
                        socket.goOnline()
                    }
                }) {
                    Text(socket.isOnline ? "Online" : "Offline")
                        .font(.caption)
                        .padding(8)
                        .background(socket.isOnline ? Color.green.opacity(0.8) : Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 10)

            Divider()

            // Chat Messages
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(socket.messages(for: selectedChatTitle), id: \.id) { message in
                            HStack {
                                if message.isFromUser {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                                } else {
                                    Text(message.text)
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .foregroundColor(.primary)
                                        .cornerRadius(12)
                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                                    Spacer()
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
                .onChange(of: socket.messages(for: selectedChatTitle).count) { _ in
                    if let last = socket.messages(for: selectedChatTitle).last {
                        withAnimation {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }
            }

            // Message Input
            MessageInputView(text: $inputText) {
                socket.setActiveChat(selectedChatTitle)
                socket.send(inputText)
                inputText = ""
            }
        }
    }

    private func send() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        socket.setActiveChat(selectedChatTitle)
        socket.send(inputText)
        inputText = ""
        isInputFocused = true
    }
}


#Preview {
    ChatListView()
}
