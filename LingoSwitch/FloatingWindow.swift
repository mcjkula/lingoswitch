//
//  FloatingWindow.swift
//  LingoSwitch
//
//  Created by Maciej Kula on 02.11.23.
//

import AppKit

class FloatingWindow: NSWindow {
    override var isMovable: Bool {
        get { return false }
        set { }
    }
    
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
