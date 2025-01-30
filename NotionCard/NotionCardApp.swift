//
//  NotionCardApp.swift
//  NotionCard
//
//  Created by BuildIn.AI on 2025/1/29.
//

import SwiftUI

@main
struct NotionCardApp: App {
    @AppStorage("NOTION_API_KEY") private var apiKey = ""
    
    var body: some Scene {
        WindowGroup {
            if !apiKey.isEmpty {
                ContentView()
            } else {
                ConfigurationView()
            }
        }
    }
}
