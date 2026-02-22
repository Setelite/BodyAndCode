//
//  TrainingType.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/4/26.
//

import Foundation

enum TrainingType: String, CaseIterable, Codable, Hashable {
    case individual = "Индивидуальная"
    case group = "Групповая"
    case online = "Онлайн"
    case monthly = "Абонемент на месяц"
}
