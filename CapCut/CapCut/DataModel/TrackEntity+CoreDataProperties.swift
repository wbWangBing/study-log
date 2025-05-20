//
//  TrackEntity+CoreDataProperties.swift
//  
//
//  Created by ByteDance on 2025/5/14.
//
//

import Foundation
import CoreData


extension TrackEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackEntity> {
        return NSFetchRequest<TrackEntity>(entityName: "TrackEntity")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var isHidden: Bool
    @NSManaged public var isMuted: Bool
    @NSManaged public var trackIndex: Int16 // 这个 trackIndex 可能是指轨道在项目中的顺序，与片段顺序无关
    @NSManaged public var trackTypeRawValue: Int16
    @NSManaged public var volume: Float
    @NSManaged public var audioEffect: AudioEffectEntity?
    @NSManaged public var clips: NSOrderedSet? // 修改类型为 NSOrderedSet?
    @NSManaged public var project: ProjectEntity?
    @NSManaged public var textAnnotation: NSSet? // 如果 textAnnotation 也需要有序，同理修改

}

// MARK: Generated accessors for clips
extension TrackEntity {

    @objc(insertObject:inClipsAtIndex:)
    @NSManaged public func insertIntoClips(_ value: ClipEntity, at idx: Int)

    @objc(removeObjectFromClipsAtIndex:)
    @NSManaged public func removeFromClips(at idx: Int)

    @objc(insertClips:atIndexes:)
    @NSManaged public func insertIntoClips(_ values: [ClipEntity], at indexes: NSIndexSet)

    @objc(removeClipsAtIndexes:)
    @NSManaged public func removeFromClips(at indexes: NSIndexSet)

    @objc(replaceObjectInClipsAtIndex:withObject:)
    @NSManaged public func replaceClips(at idx: Int, with value: ClipEntity)

    @objc(replaceClipsAtIndexes:withClips:)
    @NSManaged public func replaceClips(at indexes: NSIndexSet, with values: [ClipEntity])

    @objc(addClipsObject:)
    @NSManaged public func addToClips(_ value: ClipEntity) // Appends to the end

    @objc(removeClipsObject:)
    @NSManaged public func removeFromClips(_ value: ClipEntity)

    @objc(addClips:)
    @NSManaged public func addToClips(_ values: NSOrderedSet)

    @objc(removeClips:)
    @NSManaged public func removeFromClips(_ values: NSOrderedSet)

}

// MARK: Generated accessors for textAnnotation
extension TrackEntity {

    @objc(addTextAnnotationObject:)
    @NSManaged public func addToTextAnnotation(_ value: TextAnnotationEntity)

    @objc(removeTextAnnotationObject:)
    @NSManaged public func removeFromTextAnnotation(_ value: TextAnnotationEntity)

    @objc(addTextAnnotation:)
    @NSManaged public func addToTextAnnotation(_ values: NSSet)

    @objc(removeTextAnnotation:)
    @NSManaged public func removeFromTextAnnotation(_ values: NSSet)

}
