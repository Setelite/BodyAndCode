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

    init() {
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithTransparentBackground()
        tabAppearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        tabAppearance.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        tabAppearance.shadowColor = UIColor.white.withAlphaComponent(0.2)
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }

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
                .tint(.glassBlue)
                .onAppear {
                    // Проверяем оффлайн статус при запуске
                    Task {
                        await offlineService.updateOfflineDataCount()
                    }
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
