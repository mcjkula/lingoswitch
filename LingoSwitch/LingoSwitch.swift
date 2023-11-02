//
//  LangSwitch__Classic_App.swift
//  LangSwitch (Classic)
//
//  Created by Maciej Kula on 01.11.23.
//

import SwiftUI

@main
struct LangSwitchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            Text("Settings")
        }
    }
}

class FloatingWindow: NSWindow {
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: [.borderless], backing: backingStoreType, defer: flag)
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .floating
    }
    
    override var canBecomeKey: Bool {
        return true
    }
}
