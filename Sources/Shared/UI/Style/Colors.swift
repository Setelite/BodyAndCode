//
//  Colors.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/19/25.
//

import SwiftUI

extension Color {
    // Primary Colors
    static let primaryColor = Color(red: 0.1, green: 0.5, blue: 0.9)
    static let secondaryColor = Color(red: 0.9, green: 0.3, blue: 0.1)
    
    // Semantic Colors
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
    
    // Status Colors
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    
    // UI Colors
    static let cardBackground = Color(.systemGray6)
    static let borderColor = Color(.systemGray4)
}

// Для поддержки iOS 14 и ниже
extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let systemGray6 = Color(UIColor.systemGray6)
    static let systemGray4 = Color(UIColor.systemGray4)
}
