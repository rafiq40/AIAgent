//
//  AIAgentMindwellApp.swift
//  AIAgentMindwell
//
//  Created by Rafal on 03/08/2025.
//

import SwiftUI

@main
struct AIAgentMindwellApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
