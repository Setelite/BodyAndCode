//
//  Theme.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/5/26.
//

// Sources/Shared/UI/Style/Theme.swift
import SwiftUI
import Combine

enum Theme: String, CaseIterable {
    case system
    case light
    case dark

    var title: String {
        switch self {
        case .system: return "Системная"
        case .light: return "Светлая"
        case .dark: return "Темная"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

class ThemeManager: ObservableObject {
    private let storageKey = "selectedTheme"
    private let widgetGroupID = "group.Wowgorno.BodyCodeApp"

    @Published var currentTheme: Theme = .system {
        didSet {
            UserDefaults.standard.set(currentTheme.rawValue, forKey: storageKey)
            UserDefaults(suiteName: widgetGroupID)?.set(currentTheme.rawValue, forKey: storageKey)
        }
    }

    init() {
        if let savedTheme = UserDefaults.standard.string(forKey: storageKey),
           let theme = Theme(rawValue: savedTheme) {
            currentTheme = theme
        } else if let groupTheme = UserDefaults(suiteName: widgetGroupID)?.string(forKey: storageKey),
                  let theme = Theme(rawValue: groupTheme) {
            currentTheme = theme
        }
    }
}
