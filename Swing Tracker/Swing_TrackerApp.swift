//
//  Swing_TrackerApp.swift
//  Swing Tracker
//
//  Created by Daniel Abrams on 6/14/24.
//

import SwiftUI
import SwiftData

@main
struct Swing_TrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Session.self, Swing.self])
    }
}
