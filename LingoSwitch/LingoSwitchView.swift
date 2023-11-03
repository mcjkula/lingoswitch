//
//  LingoSwitch.swift
//  LingoSwitch
//
//  Created by Maciej Kula on 01.11.23.
//

import SwiftUI
import Carbon

struct LingoSwitchView: View {
    @ObservedObject var languageManager = LanguageManager.shared
    let scale: CGFloat = 1.25
    
    var body: some View {
        VStack(alignment: .center, spacing: 10 * scale) {
            ForEach(languageManager.languages) { languageItem in
                Text(languageItem.name)
                    .font(.system(size: 16 * scale, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 8 * scale)
                    .background(languageItem.name == languageManager.currentLanguage ? Color.blue : Color.clear)
                    .cornerRadius(8 * scale)
            }
        }
        .padding(12 * scale)
        .frame(width: 200 * scale, height: rectangleHeight)
        .background(VisualEffectView(material: .underWindowBackground, blendingMode: .withinWindow, state: .active))
        .overlay(Color.black.opacity(0.2))
        .cornerRadius(10 * scale)
        .shadow(radius: 5 * scale)
        .onAppear {
        }
    }
    
    var rectangleHeight: CGFloat {
        let rowHeight: CGFloat = 40 * scale
        let padding: CGFloat = 20 * scale
        return CGFloat(languageManager.languages.count) * rowHeight + padding
    }
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var state: NSVisualEffectView.State

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
    }
}
