//
//  UserProgressEntity+CoreDataProperties.swift
//  
//
//  Created by MAXIM GORNOSTAEV on 2/22/26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias UserProgressEntityCoreDataPropertiesSet = NSSet

extension UserProgressEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserProgressEntity> {
        return NSFetchRequest<UserProgressEntity>(entityName: "UserProgressEntity")
    }

    @NSManaged public var bodyFat: Double
    @NSManaged public var caloriesBurned: Int32
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var muscleMass: Double
    @NSManaged public var weight: Double
    @NSManaged public var workoutMinutes: Int32

}

extension UserProgressEntity : Identifiable {

}
