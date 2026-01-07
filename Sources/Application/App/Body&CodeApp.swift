// Sources/Application/App/Body&CodeApp.swift
import SwiftUI
internal import CoreData

@main
struct BodyCodeApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

    }
}



















/*@main
struct FitnessAppApp: App {
    private let persistence = PersistenceController.shared
    @StateObject private var offlineService = OfflineService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistence.container.viewContext)
                .environmentObject(offlineService)
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
                .background(Color.white)
                .cornerRadius(10)
        }
    }
}
*/
