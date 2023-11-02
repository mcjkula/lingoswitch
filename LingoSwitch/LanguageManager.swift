//
//  LanguageManager.swift
//  LingoSwitch
//
//  Created by Maciej Kula on 01.11.23.
//

import Foundation
import Carbon

class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    @Published var currentLanguage: String = ""
    @Published var previousLanguage: String? = nil
    @Published var languages: [LanguageItem] = []
    
    func fetchEnabledKeyboardLanguages() {
        let inputSources = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]
        let keyboardSources = inputSources.filter { $0.category == TISInputSource.Category.keyboardInputSource && $0.isSelectable }
        
        DispatchQueue.main.async {
            let languageNames = keyboardSources.map { $0.localizedName }.filter { $0 != "Emoji & Symbols" && !$0.contains("com.apple.PressAndHold") }
            self.languages = languageNames.map { LanguageItem(id: UUID(), name: $0) }
        }
    }
    
    func switchKeyboardLanguage() {
        guard let currentSource = TISCopyCurrentKeyboardInputSource()?.takeUnretainedValue() else {
            print("Failed to switch keyboard language.")
            return
        }
        
        let inputSources = getInputSources()
        if inputSources.isEmpty {
            print("Failed to switch keyboard language.")
            return
        }
        
        guard let currentIndex = inputSources.firstIndex(where: { $0 == currentSource }) else {
            print("Failed to switch keyboard language.")
            return
        }
        
        let nextIndex = (currentIndex + 1) % inputSources.count
        let nextSource = inputSources[nextIndex]
        TISSelectInputSource(nextSource)
        
        let newLanguageName = Unmanaged<CFString>.fromOpaque(TISGetInputSourceProperty(nextSource, kTISPropertyLocalizedName)).takeUnretainedValue() as String
        
        currentLanguage = newLanguageName
        print("Language switched from '\(previousLanguage ?? "unknown")' to '\(newLanguageName)'")
    }
    
    func reorderLanguages() {
        let inputSources = getInputSources()
        
        var languageNames = inputSources.map { $0.localizedName }
        
        languageNames.removeAll { $0 == "Emoji & Symbols" || $0.contains("com.apple.PressAndHold") }
        
        if let currentLanguageIndex = languageNames.firstIndex(of: currentLanguage) {
            languageNames.remove(at: currentLanguageIndex)
        }
        
        languageNames.sort()
        
        var languageItems = languageNames.map { LanguageItem(id: UUID(), name: $0) }
        
        languageItems.insert(LanguageItem(id: UUID(), name: currentLanguage), at: 0)
        
        languages = languageItems
    }
    
    private func getInputSources() -> [TISInputSource] {
        let inputSourceNSArray = TISCreateInputSourceList(nil, false)
            .takeRetainedValue() as NSArray
        let inputSourceList = inputSourceNSArray as! [TISInputSource]
        
        return inputSourceList.filter { source in
            source.category == TISInputSource.Category.keyboardInputSource &&
            source.isSelectable
        }
    }
}
