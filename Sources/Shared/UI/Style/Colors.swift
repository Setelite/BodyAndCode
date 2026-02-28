//
//  Colors.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/19/25.
//

import SwiftUI

extension Color {
    // Primary Colors
    static let primaryColor = Color(red: 0.43, green: 0.56, blue: 0.97)
    static let secondaryColor = Color(red: 0.83, green: 0.69, blue: 0.97)
    static let glassBlue = Color(red: 0.53, green: 0.66, blue: 0.97)
    static let glassLavender = Color(red: 0.79, green: 0.69, blue: 0.96)
    static let glassIce = Color(red: 0.84, green: 0.92, blue: 1.0)
    
    // Semantic Colors
    static let background = Color(red: 0.96, green: 0.96, blue: 0.98)
    static let secondaryBackground = Color.white.opacity(0.55)
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

extension LinearGradient {
    static var appGlassGradient: LinearGradient {
        LinearGradient(
            colors: [.glassIce, .glassBlue, .glassLavender],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.34),
                                        Color.glassBlue.opacity(0.2),
                                        Color.glassLavender.opacity(0.16)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.55), lineWidth: 1)
                    )
            )
            .shadow(color: Color.glassBlue.opacity(0.18), radius: 14, x: 0, y: 6)
    }
}

extension View {
    func glassCardStyle() -> some View {
        modifier(GlassCardModifier())
    }
}

// Для поддержки iOS 14 и ниже
extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let systemGray6 = Color(UIColor.systemGray6)
    static let systemGray4 = Color(UIColor.systemGray4)
}
