//
//  Exercise.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 11/19/25.
//

import Foundation

struct Exercise: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let muscleGroup: MuscleGroup
    let description: String?
    let demonstrationVideoUrl: String?
    
    init(id: UUID = UUID(),
         name: String,
         muscleGroup: MuscleGroup,
         description: String? = nil,
         demonstrationVideoUrl: String? = nil) {
        self.id = id
        self.name = name
        self.muscleGroup = muscleGroup
        self.description = description
        self.demonstrationVideoUrl = demonstrationVideoUrl
    }
}
