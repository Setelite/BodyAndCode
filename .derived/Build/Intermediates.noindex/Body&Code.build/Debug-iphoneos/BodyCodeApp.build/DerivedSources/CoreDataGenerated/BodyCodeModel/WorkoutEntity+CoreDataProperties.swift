//
//  WorkoutEntity+CoreDataProperties.swift
//  
//
//  Created by MAXIM GORNOSTAEV on 2/22/26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias WorkoutEntityCoreDataPropertiesSet = NSSet

extension WorkoutEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WorkoutEntity> {
        return NSFetchRequest<WorkoutEntity>(entityName: "WorkoutEntity")
    }

    @NSManaged public var calories: Int32
    @NSManaged public var coachId: UUID?
    @NSManaged public var date: Date?
    @NSManaged public var duration: Int32
    @NSManaged public var id: UUID?
    @NSManaged public var isCompleted: Bool
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var type: String?

}

extension WorkoutEntity : Identifiable {

}
