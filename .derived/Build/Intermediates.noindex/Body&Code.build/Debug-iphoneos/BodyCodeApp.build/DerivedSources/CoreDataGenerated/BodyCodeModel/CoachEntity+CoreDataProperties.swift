//
//  CoachEntity+CoreDataProperties.swift
//  
//
//  Created by MAXIM GORNOSTAEV on 2/22/26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias CoachEntityCoreDataPropertiesSet = NSSet

extension CoachEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CoachEntity> {
        return NSFetchRequest<CoachEntity>(entityName: "CoachEntity")
    }

    @NSManaged public var descriptionText: String?
    @NSManaged public var experience: String?
    @NSManaged public var id: UUID?
    @NSManaged public var imageName: String?
    @NSManaged public var isFavorite: Bool
    @NSManaged public var lastUpdated: Date?
    @NSManaged public var name: String?
    @NSManaged public var rating: Double
    @NSManaged public var reviewCount: Int32
    @NSManaged public var specialization: String?

}

extension CoachEntity : Identifiable {

}
