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
    var isPopupVisible: Bool = false
    
    init() {
        fetchEnabledKeyboardLanguages()
        setCurrentLanguage()
    }
    
    func setCurrentLanguage() {
        if let currentSource = TISCopyCurrentKeyboardInputSource()?.takeUnretainedValue() {
            currentLanguage = currentSource.localizedName
        }
    }
    
    func fetchEnabledKeyboardLanguages() {
        let inputSources = TISCreateInputSourceList(nil, false).takeRetainedValue() as! [TISInputSource]
        let keyboardSources = inputSources.filter { $0.category == TISInputSource.Category.keyboardInputSource && $0.isSelectable }
        
        DispatchQueue.main.async {
            let languageNames = keyboardSources.map { $0.localizedName }.filter { $0 != "Emoji & Symbols" && !$0.contains("com.apple.PressAndHold") }
            self.languages = languageNames.map { LanguageItem(id: UUID(), name: $0) }
        }
    }
    
    func switchKeyboardLanguage(updatePrevious: Bool = true) {
        let inputSources = getInputSources()
        let currentSource = TISCopyCurrentKeyboardInputSource()?.takeUnretainedValue()
        
        let (_, nextSource) = determineCurrentAndNextSources(inputSources: inputSources, currentSource: currentSource)
        
        if let nextSource = nextSource {
            TISSelectInputSource(nextSource)
            
            let newLanguageName = nextSource.localizedName
            if updatePrevious {
                previousLanguage = currentLanguage
            }
            currentLanguage = newLanguageName
            
            let action = updatePrevious ? "Switched" : "Continues switching"
            print("\(action) to \(newLanguageName) (which indirectly means Switched from \(previousLanguage ?? "unknown") to \(newLanguageName))")
        } else {
            print("Failed to switch keyboard language.")
        }
    }

    private func determineCurrentAndNextSources(inputSources: [TISInputSource], currentSource: TISInputSource?) -> (Int?, TISInputSource?) {
        if languages.isEmpty {
            guard let currentSource = currentSource,
                  let currentIndex = inputSources.firstIndex(where: { $0 == currentSource }) else {
                return (nil, nil)
            }
            let nextIndex = (currentIndex + 1) % inputSources.count
            return (currentIndex, inputSources[nextIndex])
        } else {
            guard let currentLanguageIndex = languages.firstIndex(where: { $0.name == currentLanguage }),
                  let nextLanguage = languages[safe: (currentLanguageIndex + 1) % languages.count],
                  let nextSource = inputSources.first(where: { $0.localizedName == nextLanguage.name }) else {
                return (nil, nil)
            }
            return (currentLanguageIndex, nextSource)
        }
    }

    
    func reorderLanguages() {
        let inputSources = getInputSources()
        
        var languageNames = inputSources.map { $0.localizedName }
        
        languageNames.removeAll { $0 == "Emoji & Symbols" || $0.contains("com.apple.PressAndHold") || $0.isEmpty }
        
        languageNames.removeAll(where: { $0 == currentLanguage || $0 == previousLanguage })
        
        var reorderedLanguages = [currentLanguage]
        
        if let previous = previousLanguage, previous != currentLanguage, !previous.isEmpty {
            reorderedLanguages.append(previous)
        }
        
        reorderedLanguages.append(contentsOf: languageNames)
        
        print("Reordered languages: \(reorderedLanguages)")
        
        DispatchQueue.main.async {
            self.objectWillChange.send()
            self.languages = reorderedLanguages.map { LanguageItem(id: UUID(), name: $0) }
        }
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

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
