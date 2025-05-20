//
//  AudioEffectEntity+CoreDataProperties.swift
//  
//
//  Created by ByteDance on 2025/5/14.
//
//

import Foundation
import CoreData


extension AudioEffectEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AudioEffectEntity> {
        return NSFetchRequest<AudioEffectEntity>(entityName: "AudioEffectEntity")
    }

    @NSManaged public var duration: Double
    @NSManaged public var effectType: String?
    @NSManaged public var id: UUID?
    @NSManaged public var parametersData: Data?
    @NSManaged public var startTimeInParent: Double
    @NSManaged public var clip: ClipEntity?
    @NSManaged public var track: TrackEntity?

}
