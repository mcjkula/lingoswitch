//
//  LingoSwitchApp.swift
//  LingoSwitch
//
//  Created by Maciej Kula on 01.11.23.
//

import SwiftUI

@main
struct LingoSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            Text("Settings")
        }
    }
}
