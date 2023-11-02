//
//  TISInputSourceExtensions.swift
//  LingoSwitch
//
//  Created by Maciej Kula on 02.11.23.
//

import Carbon

extension TISInputSource {
    enum Category {
        static var keyboardInputSource: String {
            return kTISCategoryKeyboardInputSource as String
        }
    }
    
    var category: String {
        getProperty(kTISPropertyInputSourceCategory) as! String
    }
    
    var isSelectable: Bool {
        getProperty(kTISPropertyInputSourceIsSelectCapable) as! Bool
    }
    
    var localizedName: String {
        getProperty(kTISPropertyLocalizedName) as! String
    }
    
    private func getProperty(_ key: CFString) -> AnyObject? {
        guard let cfType = TISGetInputSourceProperty(self, key) else { return nil }
        return Unmanaged<AnyObject>.fromOpaque(cfType).takeUnretainedValue()
    }
}
