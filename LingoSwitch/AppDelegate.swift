//
//  AppDelegate.swift
//  LingoSwitch
//
//  Created by Maciej Kula on 01.11.23.
//

import AppKit
import SwiftUI
import Carbon

class AppDelegate: NSObject, NSApplicationDelegate {
    var floatingWindow: FloatingWindow?
    let languageManager = LanguageManager.shared
    var statusBarItem: NSStatusItem?
    var hideWindowTimer: DispatchWorkItem?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        configureStatusBar()
        addGlobalEventMonitor()
    }
    
    private func configureStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusBarItem?.button {
            button.image = NSImage(systemSymbolName: "globe", accessibilityDescription: nil)
        }
        
        let statusBarMenu = NSMenu(title: "Status Bar Menu")
        statusBarMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusBarItem?.menu = statusBarMenu
    }
    
    private func addGlobalEventMonitor() {
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            if event.modifierFlags.contains(.function) {
                self?.languageManager.switchKeyboardLanguage()
                self?.toggleFloatingWindow()
                self?.resetHideFloatingWindowTimer()
            }
        }
    }
    
    private func toggleFloatingWindow() {
        if floatingWindow == nil {
            showFloatingWindow()
        } else {
            hideFloatingWindow()
        }
    }
    
    private func showFloatingWindow() {
        guard floatingWindow == nil else { return }
        
        let windowSize = NSSize(width: 300, height: 200)
        if let screen = NSScreen.main {
            let screenRect = screen.frame
            let windowOrigin = NSPoint(x: screenRect.midX - windowSize.width / 2, y: screenRect.midY - windowSize.height / 2)
            let windowRect = NSRect(origin: windowOrigin, size: windowSize)
            
            floatingWindow = FloatingWindow(contentRect: windowRect, styleMask: [.borderless], backing: .buffered, defer: false)
            floatingWindow?.contentView = NSHostingView(rootView: LingoSwitchView())
            
            floatingWindow?.setFrame(windowRect, display: true)
            floatingWindow?.makeKeyAndOrderFront(nil)
            floatingWindow?.setFrame(windowRect, display: true)
        } else {
            print("No main screen found")
        }
    }
    
    private func hideFloatingWindow() {
            hideWindowTimer?.cancel()
            hideWindowTimer = DispatchWorkItem { [weak self] in
                self?.floatingWindow?.orderOut(nil)
                self?.floatingWindow = nil
                self?.languageManager.reorderLanguages()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: hideWindowTimer!)
        }
    
    private func resetHideFloatingWindowTimer() {
        hideWindowTimer?.cancel()
        hideWindowTimer = DispatchWorkItem { [weak self] in
            self?.floatingWindow?.orderOut(nil)
            self?.floatingWindow = nil
            self?.languageManager.reorderLanguages()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: hideWindowTimer!)
    }
}
