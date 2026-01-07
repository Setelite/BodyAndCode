//
//  WorkoutSet.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/19/25.
//

import Foundation

struct WorkoutSet: Identifiable, Codable, Hashable {
    let id: UUID
    let exerciseId: UUID
    let workoutPlanId: UUID
    let setNumber: Int
    let targetReps: Int
    let targetWeight: Double
    var completedReps: Int?
    var completedWeight: Double?
    var isCompleted: Bool
    let date: Date
    
    init(id: UUID = UUID(),
         exerciseId: UUID,
         workoutPlanId: UUID,
         setNumber: Int,
         targetReps: Int,
         targetWeight: Double,
         completedReps: Int? = nil,
         completedWeight: Double? = nil,
         isCompleted: Bool = false,
         date: Date = Date()) {
        self.id = id
        self.exerciseId = exerciseId
        self.workoutPlanId = workoutPlanId
        self.setNumber = setNumber
        self.targetReps = targetReps
        self.targetWeight = targetWeight
        self.completedReps = completedReps
        self.completedWeight = completedWeight
        self.isCompleted = isCompleted
        self.date = date
    }
}
