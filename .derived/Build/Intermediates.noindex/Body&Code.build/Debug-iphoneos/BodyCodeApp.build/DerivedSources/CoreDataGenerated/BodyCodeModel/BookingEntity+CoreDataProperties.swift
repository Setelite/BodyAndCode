//
//  BookingEntity+CoreDataProperties.swift
//  
//
//  Created by MAXIM GORNOSTAEV on 2/22/26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias BookingEntityCoreDataPropertiesSet = NSSet

extension BookingEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookingEntity> {
        return NSFetchRequest<BookingEntity>(entityName: "BookingEntity")
    }

    @NSManaged public var coachId: UUID?
    @NSManaged public var createdAt: Date?
    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var notes: String?
    @NSManaged public var status: String?
    @NSManaged public var time: String?
    @NSManaged public var trainingType: String?
    @NSManaged public var updatedAt: Date?

}

extension BookingEntity : Identifiable {

}
