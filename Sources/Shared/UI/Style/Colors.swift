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

    // Adaptive UI Colors
    static let appSurface = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor(red: 0.13, green: 0.14, blue: 0.16, alpha: 1.0)
        : UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1.0)
    })

    static let appCardSurface = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor(red: 0.18, green: 0.19, blue: 0.22, alpha: 0.95)
        : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.72)
    })

    static let appButtonSurface = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor(red: 0.24, green: 0.26, blue: 0.30, alpha: 1.0)
        : UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.92)
    })

    static let appButtonBorder = Color(UIColor { trait in
        trait.userInterfaceStyle == .dark
        ? UIColor.white.withAlphaComponent(0.18)
        : UIColor.black.withAlphaComponent(0.12)
    })
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

struct AppContrastButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.appButtonSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.appButtonBorder, lineWidth: 1)
                    )
            )
            .opacity(configuration.isPressed ? 0.86 : 1)
    }
}

extension View {
    func glassCardStyle() -> some View {
        modifier(GlassCardModifier())
    }

    func appContrastButton() -> some View {
        buttonStyle(AppContrastButtonStyle())
    }
}

// Для поддержки iOS 14 и ниже
extension Color {
    static let systemBackground = Color(UIColor.systemBackground)
    static let secondarySystemBackground = Color(UIColor.secondarySystemBackground)
    static let systemGray6 = Color(UIColor.systemGray6)
    static let systemGray4 = Color(UIColor.systemGray4)
}
