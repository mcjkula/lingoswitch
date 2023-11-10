//
//  AppDelegate.swift
//  LingoSwitch
//
//  Created by Maciej Kula on 01.11.23.
//

import AppKit
import SwiftUI
import Carbon
import LaunchAtLogin

class AppDelegate: NSObject, NSApplicationDelegate {
    var floatingWindow: FloatingWindow?
    let languageManager = LanguageManager.shared
    var statusBarItem: NSStatusItem?
    var hideWindowTimer: DispatchWorkItem?
    var lingoSwitchView: LingoSwitchView?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        lingoSwitchView = LingoSwitchView()
        configureStatusBar()
        addGlobalEventMonitor()
        languageManager.setCurrentLanguage()
    }
    
    private func configureStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusBarItem?.button {
            if let iconImage = NSImage(named: "StatusIcon") {
                button.image = iconImage
            }
        }
        
        let statusBarMenu = NSMenu(title: "Status Bar Menu")
        
        let launchAtLoginMenuItem = NSMenuItem(
            title: "Launch on Startup",
            action: #selector(toggleLaunchAtLogin(_:)),
            keyEquivalent: ""
        )
        launchAtLoginMenuItem.state = LaunchAtLogin.isEnabled ? .on : .off
        statusBarMenu.addItem(launchAtLoginMenuItem)

        statusBarMenu.addItem(NSMenuItem.separator())
        
        statusBarMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusBarItem?.menu = statusBarMenu
    }
    
    @objc private func toggleLaunchAtLogin(_ sender: NSMenuItem) {
            sender.state = (sender.state == .on) ? .off : .on
            LaunchAtLogin.isEnabled = (sender.state == .on)
        }
    
    private func addGlobalEventMonitor() {
        NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            if event.modifierFlags.contains(.function) {
                if self?.floatingWindow == nil {
                    self?.languageManager.switchKeyboardLanguage(updatePrevious: true)
                } else {
                    self?.languageManager.switchKeyboardLanguage(updatePrevious: false)
                }
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
        guard floatingWindow == nil, let lingoSwitchView = lingoSwitchView else { return }

        let scale: CGFloat = 1.25
        let windowSize = NSSize(width: 300 * scale, height: 200 * scale)
        let windowRect = NSRect(origin: .zero, size: windowSize)

        floatingWindow = FloatingWindow(contentRect: windowRect, styleMask: [.borderless], backing: .buffered, defer: false)
        floatingWindow?.contentView = NSHostingView(rootView: lingoSwitchView)
        floatingWindow?.center()
        
        let yOffset: CGFloat = -250
        floatingWindow?.setFrameOrigin(NSPoint(x: floatingWindow!.frame.origin.x,
                                               y: floatingWindow!.frame.origin.y + yOffset))
        
        floatingWindow?.makeKeyAndOrderFront(nil)
    }
    
    private func hideFloatingWindow() {
        hideWindowTimer?.cancel()
        hideWindowTimer = DispatchWorkItem { [weak self] in
            self?.floatingWindow?.orderOut(nil)
            self?.floatingWindow = nil
            self?.languageManager.reorderLanguages()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50, execute: hideWindowTimer!)
    }
    
    private func resetHideFloatingWindowTimer() {
        hideWindowTimer?.cancel()
        hideWindowTimer = DispatchWorkItem { [weak self] in
            self?.floatingWindow?.orderOut(nil)
            self?.floatingWindow = nil
            self?.languageManager.reorderLanguages()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50, execute: hideWindowTimer!)
    }
}
