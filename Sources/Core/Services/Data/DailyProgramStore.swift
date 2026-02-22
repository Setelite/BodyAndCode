//
//  DailyProgramStore.swift
//  Body&Code
//
//  Created by Codex on 2/21/26.
//

import Foundation
import Combine

@MainActor
final class DailyProgramStore: ObservableObject {
    @Published var program: DailyProgram

    private var dayOfWeek: DayOfWeek
    private static let storageKey = "daily_programs_v1"
    private let userDefaults: UserDefaults

    init(date: Date = Date(), userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        let day = DayOfWeek.from(date)
        self.dayOfWeek = day

        let stored = Self.loadAllPrograms(userDefaults: userDefaults, storageKey: Self.storageKey)
        if let existing = stored[day.rawValue] {
            self.program = existing
        } else {
            let fresh = DailyProgram.sample(for: day)
            self.program = fresh
            saveProgram(fresh, for: day)
        }
    }

    func refreshForToday() {
        let today = DayOfWeek.from(Date())
        guard today != dayOfWeek else { return }
        dayOfWeek = today

        let stored = Self.loadAllPrograms(userDefaults: userDefaults, storageKey: Self.storageKey)
        if let existing = stored[today.rawValue] {
            program = existing
        } else {
            let fresh = DailyProgram.sample(for: today)
            program = fresh
            saveProgram(fresh, for: today)
        }
    }

    func persist() {
        saveProgram(program, for: dayOfWeek)
    }

    private static func loadAllPrograms(userDefaults: UserDefaults, storageKey: String) -> [String: DailyProgram] {
        guard let data = userDefaults.data(forKey: storageKey) else { return [:] }
        do {
            return try JSONDecoder().decode([String: DailyProgram].self, from: data)
        } catch {
            return [:]
        }
    }

    private func saveProgram(_ program: DailyProgram, for day: DayOfWeek) {
        var all = Self.loadAllPrograms(userDefaults: userDefaults, storageKey: Self.storageKey)
        all[day.rawValue] = program
        do {
            let data = try JSONEncoder().encode(all)
            userDefaults.set(data, forKey: Self.storageKey)
        } catch {
            // no-op
        }
    }
}
