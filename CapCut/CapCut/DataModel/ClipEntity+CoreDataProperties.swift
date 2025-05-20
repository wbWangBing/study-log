//
//  ClipEntity+CoreDataProperties.swift
//  
//
//  Created by ByteDance on 2025/5/14.
//
//

import Foundation
import CoreData


extension ClipEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClipEntity> {
        return NSFetchRequest<ClipEntity>(entityName: "ClipEntity")
    }

    @NSManaged public var adjustmentsData: Data?
    @NSManaged public var durationInTrack: Double
    @NSManaged public var filtersData: Data?
    @NSManaged public var id: UUID?
    @NSManaged public var isMuted: Bool
    @NSManaged public var playbackSpeed: Float
    @NSManaged public var sourceDuration: Double
    @NSManaged public var sourceStartTime: Double
    @NSManaged public var startTimeInTrack: Double
    @NSManaged public var transformData: Data?
    @NSManaged public var volume: Float
    @NSManaged public var audioEffects: NSSet?
    @NSManaged public var mediaAsset: MediaAssetEntity?
    @NSManaged public var textAnnotations: NSSet?
    @NSManaged public var track: TrackEntity?

}

// MARK: Generated accessors for audioEffects
extension ClipEntity {

    @objc(addAudioEffectsObject:)
    @NSManaged public func addToAudioEffects(_ value: AudioEffectEntity)

    @objc(removeAudioEffectsObject:)
    @NSManaged public func removeFromAudioEffects(_ value: AudioEffectEntity)

    @objc(addAudioEffects:)
    @NSManaged public func addToAudioEffects(_ values: NSSet)

    @objc(removeAudioEffects:)
    @NSManaged public func removeFromAudioEffects(_ values: NSSet)

}

// MARK: Generated accessors for textAnnotations
extension ClipEntity {

    @objc(addTextAnnotationsObject:)
    @NSManaged public func addToTextAnnotations(_ value: TextAnnotationEntity)

    @objc(removeTextAnnotationsObject:)
    @NSManaged public func removeFromTextAnnotations(_ value: TextAnnotationEntity)

    @objc(addTextAnnotations:)
    @NSManaged public func addToTextAnnotations(_ values: NSSet)

    @objc(removeTextAnnotations:)
    @NSManaged public func removeFromTextAnnotations(_ values: NSSet)

}
