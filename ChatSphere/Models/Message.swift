//
//  Message.swift
//  ChatSphere
//
//  Created by Sreeni on 25/04/25.
//

import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let text: String
    let isFromUser: Bool
    let timestamp: Date
}





