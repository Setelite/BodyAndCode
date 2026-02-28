//
//  NutritionEntity+CoreDataProperties.swift
//  
//
//  Created by MAXIM GORNOSTAEV on 2/22/26.
//
//  This file was automatically generated and should not be edited.
//

public import Foundation
public import CoreData


public typealias NutritionEntityCoreDataPropertiesSet = NSSet

extension NutritionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NutritionEntity> {
        return NSFetchRequest<NutritionEntity>(entityName: "NutritionEntity")
    }

    @NSManaged public var calories: Int32
    @NSManaged public var carbs: Double
    @NSManaged public var date: Date?
    @NSManaged public var fat: Double
    @NSManaged public var id: UUID?
    @NSManaged public var mealType: String?
    @NSManaged public var name: String?
    @NSManaged public var notes: String?
    @NSManaged public var protein: Double

}

extension NutritionEntity : Identifiable {

}
