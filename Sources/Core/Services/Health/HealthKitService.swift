//
//  HealthKitService.swift
//  Body&Code
//
//  Created by MAXIM GORNOSTAEV on 1/5/26.
//

// Sources/Core/Services/Health/HealthKitService.swift
import HealthKit

class HealthKitService {
    private let healthStore = HKHealthStore()
    
    func requestAuthorization() {
        let typesToShare: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!
        ]
        
        let typesToRead: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .bodyMass)!
        ]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success {
                print("HealthKit доступ разрешен")
            } else if let error = error {
                print("Ошибка HealthKit: \(error.localizedDescription)")
            }
        }
    }
}
