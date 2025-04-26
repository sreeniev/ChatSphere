//
//  ChatSphereApp.swift
//  ChatSphere
//
//  Created by Sreeni on 25/04/25.
//

import SwiftUI

@main
struct ChatApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ChatListView()
            }
        }
    }
}
