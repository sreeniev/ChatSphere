//
//  MessageInputView.swift
//  ChatSphere
//
//  Created by Sreeni on 26/04/25.
//

import SwiftUI

struct MessageInputView: View {
    @Binding var text: String
    var onSend: () -> Void

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 12) {
            TextField("Type a message...", text: $text)
                .padding(12)
                .focused($isFocused)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(25)
                .onSubmit {
                    send()
                }

            Button(action: send) {
                Image(systemName: "paperplane.fill")
                    .foregroundColor(.white)
                    .padding(12)
                    .background(text.trimmingCharacters(in: .whitespaces).isEmpty ? Color.gray : Color.blue)
                    .clipShape(Circle())
            }
            .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
    }

    private func send() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        onSend()
        isFocused = true
    }
}

#Preview {
    MessageInputView(text: .constant(""), onSend: {})
}
