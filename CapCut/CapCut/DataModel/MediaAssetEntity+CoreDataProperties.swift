//
//  MediaAssetEntity+CoreDataProperties.swift
//  
//
//  Created by ByteDance on 2025/5/14.
//
//

import Foundation
import CoreData


extension MediaAssetEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MediaAssetEntity> {
        return NSFetchRequest<MediaAssetEntity>(entityName: "MediaAssetEntity")
    }

    @NSManaged public var duration: Double
    @NSManaged public var height: Int32
    @NSManaged public var id: UUID
    @NSManaged public var importDate: Date?
    @NSManaged public var mediaTypeRawValue: Int16
    @NSManaged public var originalFilePath: String?
    @NSManaged public var width: Int32
    @NSManaged public var clips: NSSet?
    @NSManaged public var project: ProjectEntity

}

// MARK: Generated accessors for clips
extension MediaAssetEntity {

    @objc(addClipsObject:)
    @NSManaged public func addToClips(_ value: ClipEntity)

    @objc(removeClipsObject:)
    @NSManaged public func removeFromClips(_ value: ClipEntity)

    @objc(addClips:)
    @NSManaged public func addToClips(_ values: NSSet)

    @objc(removeClips:)
    @NSManaged public func removeFromClips(_ values: NSSet)

}
