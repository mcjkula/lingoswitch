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
    
    var id: String {
        return getProperty(kTISPropertyInputSourceID) as! String
    }

    var name: String {
        return getProperty(kTISPropertyLocalizedName) as! String
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
    var sourceLanguages: [String] {
        return getProperty(kTISPropertyInputSourceLanguages) as! [String]
    }

    var iconImageURL: URL? {
        return getProperty(kTISPropertyIconImageURL) as! URL?
    }

    var iconRef: IconRef? {
        return OpaquePointer(TISGetInputSourceProperty(self, kTISPropertyIconRef)) as IconRef?
    }
    
    private func getProperty(_ key: CFString) -> AnyObject? {
        let cfType = TISGetInputSourceProperty(self, key)
        if (cfType != nil) {
            return Unmanaged<AnyObject>.fromOpaque(cfType!).takeUnretainedValue()
        } else {
            return nil
        }
    }
}
