//
//  CoachRout.swift
//  BodyCodeApp
//
//  Created by MAXIM GORNOSTAEV on 1/10/26.
//

import Foundation

enum CoachRoute: Hashable {
    case list
    case detail(coachID: UUID)
    case booking(coachID: UUID, type: TrainingType)
    case reviews(coachID: UUID)
}
