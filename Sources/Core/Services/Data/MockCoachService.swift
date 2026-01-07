//
//  MockCoachService.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/4/26.
//

// Sources/Core/Services/Data/MockCoachService.swift
import Foundation

#if DEBUG
class MockCoachService: CoachServiceProtocol {
    var shouldFail = false
    var delay: UInt64 = 500_000_000 // 0.5 секунды
    
    func fetchCoaches() async throws -> [Coach] {
        try await Task.sleep(nanoseconds: delay)
        
        if shouldFail {
            throw CoachError.networkError
        }
        
        return Coach.mockData
    }
    
    func fetchCoachDetails(id: UUID) async throws -> Coach {
        try await Task.sleep(nanoseconds: delay)
        
        if shouldFail {
            throw CoachError.coachNotFound
        }
        
        return Coach.mockData.first { $0.id == id } ?? Coach.sample
    }
    
    func bookSession(coachId: UUID, date: Date, type: TrainingType) async throws -> Bool {
        try await Task.sleep(nanoseconds: delay)
        
        if shouldFail {
            throw CoachError.bookingFailed
        }
        
        return true
    }
}
#endif
