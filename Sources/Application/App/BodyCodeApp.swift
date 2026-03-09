// Sources/Application/App/Body&CodeApp.swift
import SwiftUI
import UIKit
internal import CoreData

/*@main
struct BodyCodeApp: App {
    @StateObject private var offlineService = OfflineService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(offlineService)
        }
    }
}
*/















@main
struct BodyCodeApp: App {
    private let persistence = PersistenceController.shared
    @StateObject private var offlineService = OfflineService()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var notificationService = NotificationService.shared

    init() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        tabAppearance.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor.black.withAlphaComponent(0.30)
            : UIColor.white.withAlphaComponent(0.35)
        }
        tabAppearance.shadowColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.10)
            : UIColor.black.withAlphaComponent(0.08)
        }

        let selectedColor = UIColor.systemTeal
        let unselectedColor = UIColor.secondaryLabel

        tabAppearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        tabAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        tabAppearance.stackedLayoutAppearance.normal.iconColor = unselectedColor
        tabAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: unselectedColor]

        tabAppearance.inlineLayoutAppearance = tabAppearance.stackedLayoutAppearance
        tabAppearance.compactInlineLayoutAppearance = tabAppearance.stackedLayoutAppearance

        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        UITabBar.appearance().tintColor = selectedColor
        UITabBar.appearance().unselectedItemTintColor = unselectedColor

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithTransparentBackground()
        navAppearance.backgroundEffect = nil
        navAppearance.backgroundColor = .clear
        navAppearance.shadowColor = .clear
        navAppearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        navAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance

        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UICollectionView.appearance().backgroundColor = .clear
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(offlineService)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.currentTheme.colorScheme)
                .tint(.glassBlue)
                .task {
                    await offlineService.updateOfflineDataCount()
                    await notificationService.prepare()
                    await notificationService.checkPermissionStatus()
                }
        }
    }
}
// MARK: - Supporting Views
struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            ProgressView()
                .scaleEffect(1.5)
                .padding(20)
                .background(Color.white.opacity(0.58))
                .cornerRadius(10)
        }
    }
}
