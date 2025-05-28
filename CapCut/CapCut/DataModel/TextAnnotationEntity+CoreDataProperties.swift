//
//  TextAnnotationEntity+CoreDataProperties.swift
//  
//
//  Created by ByteDance on 2025/5/14.
//
//

import Foundation
import CoreData


extension TextAnnotationEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TextAnnotationEntity> {
        return NSFetchRequest<TextAnnotationEntity>(entityName: "TextAnnotationEntity")
    }

    @NSManaged public var animationInData: Data?
    @NSManaged public var animationOutData: Data?
    @NSManaged public var backgroundColorData: Data?
    @NSManaged public var duration: Double
    @NSManaged public var fontName: String?
    @NSManaged public var fontSize: Float
    @NSManaged public var id: UUID?
    @NSManaged public var positionX: Float
    @NSManaged public var positionY: Float
    @NSManaged public var startTimeInTrack: Double
    @NSManaged public var text: String?
    @NSManaged public var textColorData: Data?
    @NSManaged public var clip: ClipEntity?
    @NSManaged public var track: TrackEntity?

}
