//
//  OfflineSettingsView.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/6/26.
//

// Sources/Features/Settings/Views/OfflineSettingsView.swift
import SwiftUI

struct OfflineSettingsView: View {
    @EnvironmentObject private var offlineService: OfflineService
    @State private var showingClearAlert = false
    @State private var showingSyncAlert = false
    
    var body: some View {
        List {
            // Статус
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(statusTitle)
                            .font(.headline)
                            .foregroundColor(statusColor)
                        
                        Text(statusDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: statusIcon)
                        .font(.title2)
                        .foregroundColor(statusColor)
                }
                .padding(.vertical, 4)
            }
            
            // Данные
            Section("Оффлайн данные") {
                DataCountRow(title: "Тренеры", count: offlineService.offlineDataCount.coaches)
                DataCountRow(title: "Тренировки", count: offlineService.offlineDataCount.workouts)
                DataCountRow(title: "Питание", count: offlineService.offlineDataCount.nutrition)
                DataCountRow(title: "Прогресс", count: offlineService.offlineDataCount.progress)
                
                HStack {
                    Text("Всего данных")
                    Spacer()
                    Text("\(offlineService.offlineDataCount.total)")
                        .fontWeight(.medium)
                }
                
                HStack {
                    Text("Размер БД")
                    Spacer()
                    Text(offlineService.getDatabaseSize())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Последняя синхронизация
            if let lastSync = offlineService.lastSyncDate {
                Section("Последняя синхронизация") {
                    HStack {
                        Text("Дата")
                        Spacer()
                        Text(lastSync.formatted(date: .long, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Действия
            Section {
                Button {
                    syncData()
                } label: {
                    HStack {
                        Image(systemName: "arrow.clockwise")
                        Text("Синхронизировать")
                        Spacer()
                        if offlineService.syncInProgress {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                    }
                }
                .disabled(offlineService.syncInProgress || offlineService.isOfflineMode)
                
                Button(role: .destructive) {
                    showingClearAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Очистить оффлайн данные")
                    }
                }
                .disabled(offlineService.offlineDataCount.total == 0)
            }
            
            // Информация
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Оффлайн режим позволяет:")
                        .font(.caption)
                        .fontWeight(.medium)
                    
                    Text("• Просматривать тренеров\n• Записывать тренировки\n• Вести дневник питания\n• Отслеживать прогресс")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Оффлайн режим")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Очистить данные?", isPresented: $showingClearAlert) {
            Button("Отмена", role: .cancel) { }
            Button("Очистить", role: .destructive) {
                clearOfflineData()
            }
        } message: {
            Text("Все оффлайн данные будут удалены. Это действие нельзя отменить.")
        }
        .alert("Синхронизация", isPresented: $showingSyncAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Синхронизация завершена. Все данные обновлены.")
        }
    }
    
    private var statusTitle: String {
        offlineService.isOfflineMode ? "Оффлайн режим" : "Онлайн режим"
    }
    
    private var statusDescription: String {
        offlineService.isOfflineMode
            ? "Работа с локальными данными"
            : "Соединение с интернетом установлено"
    }
    
    private var statusIcon: String {
        offlineService.isOfflineMode ? "wifi.slash" : "wifi"
    }
    
    private var statusColor: Color {
        offlineService.isOfflineMode ? .orange : .green
    }
    
    private func syncData() {
        Task {
            await offlineService.syncIfNeeded()
            showingSyncAlert = true
        }
    }
    
    private func clearOfflineData() {
        Task {
            do {
                try await offlineService.clearOfflineData()
            } catch {
                print("❌ Ошибка очистки данных: \(error)")
            }
        }
    }
}

struct DataCountRow: View {
    let title: String
    let count: Int
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text("\(count)")
                .fontWeight(.medium)
                .foregroundColor(count > 0 ? .primary : .secondary)
        }
    }
}

#if DEBUG
struct OfflineSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OfflineSettingsView()
                .environmentObject(OfflineService())
        }
    }
}
#endif
