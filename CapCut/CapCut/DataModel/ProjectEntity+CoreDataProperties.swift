//
//  ProjectEntity+CoreDataProperties.swift
//  
//
//  Created by ByteDance on 2025/5/14.
//
//

import Foundation
import CoreData


extension ProjectEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ProjectEntity> {
        return NSFetchRequest<ProjectEntity>(entityName: "ProjectEntity")
    }

    @NSManaged public var coverImagePath: String?
    @NSManaged public var creationDate: Date?
    @NSManaged public var globalAudioSettingsData: Data?
    @NSManaged public var id: UUID?
    @NSManaged public var lastModifiedDate: Date?
    @NSManaged public var outputSettingsData: Data?
    @NSManaged public var title: String
    @NSManaged public var mediaAssets: NSOrderedSet // 假设 mediaAssets 也可能需要有序，如果之前是 NSSet，也应考虑
    @NSManaged public var tracks: NSOrderedSet? // 修改类型为 NSOrderedSet?

}

// MARK: Generated accessors for mediaAssets
extension ProjectEntity {

    @objc(insertObject:inMediaAssetsAtIndex:)
    @NSManaged public func insertIntoMediaAssets(_ value: MediaAssetEntity, at idx: Int)

    @objc(removeObjectFromMediaAssetsAtIndex:)
    @NSManaged public func removeFromMediaAssets(at idx: Int)

    @objc(insertMediaAssets:atIndexes:)
    @NSManaged public func insertIntoMediaAssets(_ values: [MediaAssetEntity], at indexes: NSIndexSet)

    @objc(removeMediaAssetsAtIndexes:)
    @NSManaged public func removeFromMediaAssets(at indexes: NSIndexSet)

    @objc(replaceObjectInMediaAssetsAtIndex:withObject:)
    @NSManaged public func replaceMediaAssets(at idx: Int, with value: MediaAssetEntity)

    @objc(replaceMediaAssetsAtIndexes:withMediaAssets:)
    @NSManaged public func replaceMediaAssets(at indexes: NSIndexSet, with values: [MediaAssetEntity])

    @objc(addMediaAssetsObject:)
    @NSManaged public func addToMediaAssets(_ value: MediaAssetEntity)

    @objc(removeMediaAssetsObject:)
    @NSManaged public func removeFromMediaAssets(_ value: MediaAssetEntity)

    @objc(addMediaAssets:)
    @NSManaged public func addToMediaAssets(_ values: NSOrderedSet)

    @objc(removeMediaAssets:)
    @NSManaged public func removeFromMediaAssets(_ values: NSOrderedSet)

}

// MARK: Generated accessors for tracks
extension ProjectEntity {

    @objc(insertObject:inTracksAtIndex:)
    @NSManaged public func insertIntoTracks(_ value: TrackEntity, at idx: Int)

    @objc(removeObjectFromTracksAtIndex:)
    @NSManaged public func removeFromTracks(at idx: Int)

    @objc(insertTracks:atIndexes:)
    @NSManaged public func insertIntoTracks(_ values: [TrackEntity], at indexes: NSIndexSet)

    @objc(removeTracksAtIndexes:)
    @NSManaged public func removeFromTracks(at indexes: NSIndexSet)

    @objc(replaceObjectInTracksAtIndex:withObject:)
    @NSManaged public func replaceTracks(at idx: Int, with value: TrackEntity)

    @objc(replaceTracksAtIndexes:withTracks:)
    @NSManaged public func replaceTracks(at indexes: NSIndexSet, with values: [TrackEntity])

    @objc(addTracksObject:)
    @NSManaged public func addToTracks(_ value: TrackEntity) // Appends to the end

    @objc(removeTracksObject:)
    @NSManaged public func removeFromTracks(_ value: TrackEntity)

    @objc(addTracks:)
    @NSManaged public func addToTracks(_ values: NSOrderedSet)

    @objc(removeTracks:)
    @NSManaged public func removeFromTracks(_ values: NSOrderedSet)

}
