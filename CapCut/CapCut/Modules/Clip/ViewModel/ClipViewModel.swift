//
//  ClipViewModel.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/9.
//

import Foundation
import AVFoundation
import UIKit // For UIImage
import Combine // For @Published
import CoreData // 引入 CoreData

// 媒体类型枚举
enum MediaType: Int16 {
    case video = 0
    case image = 1
    case audio = 2
}

// Define VideoLoadState, can be here or in a shared file
enum VideoLoadState {
    case noVideo // 没有项目或没有媒体
    case videoLoaded // 项目已加载并有媒体资源
}

class ClipViewModel {
    // MARK: - Published Properties
    @Published private(set) var videoState: VideoLoadState = .noVideo
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var playerLayer: AVPlayerLayer?
    // 新增: 用于 PlayerComponent 显示媒体池
    @Published private(set) var mediaAssetsForDisplay: [MediaAssetDisplayViewModel] = []

    // MARK: - Private Properties
    private var player: AVPlayer?
    private var playerTimeObserverToken: Any?

    // Core Data Related
    private var managedObjectContext: NSManagedObjectContext // 注入或从 CoreDataStack 获取
    public var currentProjectEntity: ProjectEntity? // 当前正在编辑的 Core Data ProjectEntity
    private var currentDraftProjectItem: ProjectItem? // 与 currentProjectEntity 对应的 ProjectItem (用于列表显示)
    
    //其他属性
    let timelineNeedsUpdate = PassthroughSubject<Void, Never>() // 新增
    
    // MARK: - Initialization
    // 修改 init 以接收 MOC，移除了不存在的 CoreDataStack 默认值
    init(projectItem: ProjectItem? = nil, managedObjectContext: NSManagedObjectContext) { // managedObjectContext 现在是必需的
        self.managedObjectContext = managedObjectContext
        
        if let existingProjectItem = projectItem {
            if existingProjectItem.status == .draft, let projectEntityURIString = existingProjectItem.projectFilePath {
                // 这是草稿项目，需要从 Core Data 加载 ProjectEntity
                if let projectEntityURI = URL(string: projectEntityURIString),
                   let entityID = managedObjectContext.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: projectEntityURI),
                   let projectEntity = try? managedObjectContext.existingObject(with: entityID) as? ProjectEntity {
                    self.currentProjectEntity = projectEntity
                    self.currentDraftProjectItem = existingProjectItem
                    loadMediaAssetsForCurrentProject()
                    if let firstAssetURL = getFirstMediaAssetURLFromCurrentProject() {
                        setupPlayer(with: firstAssetURL) // 初始播放第一个素材
                        self.videoState = .videoLoaded
                    } else {
                        self.videoState = .noVideo // 草稿可能没有媒体
                    }
                } else {
                    print("错误：无法从 URI 加载 ProjectEntity 草稿: \(projectEntityURIString)")
                    self.videoState = .noVideo
                }
            } else if existingProjectItem.status == .project, let videoFilePath = existingProjectItem.projectFilePath {
                // 这是已完成的项目，直接加载视频文件
                let videoURL = URL(fileURLWithPath: videoFilePath)
                setupPlayer(with: videoURL)
                self.videoState = .videoLoaded
                // 对于已完成项目，mediaAssetsForDisplay 通常为空，因为它们不用于编辑
            } else {
                self.videoState = .noVideo
            }
        } else {
            self.videoState = .noVideo // 没有传入 projectItem，是全新创建流程
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        if let token = playerTimeObserverToken {
            player?.removeTimeObserver(token)
            playerTimeObserverToken = nil
        }
    }

    // MARK: - Video Loading and Management
    
    // 当用户从 UIImagePickerController 选择视频后调用
    func handleVideoImport(from url: URL) {
        if self.currentProjectEntity == nil {
            // 这是新项目的第一个视频
            createNewProjectAndAddFirstMedia(videoURL: url)
        } else {
            // 为现有项目添加更多媒体
            addMediaAssetToCurrentProject(videoURL: url, isFirstAssetInProject: false)
        }
    }

    private func createNewProjectAndAddFirstMedia(videoURL: URL) {
        // 1. 创建 ProjectEntity (Core Data)
        let projectEntity = ProjectEntity(context: managedObjectContext)
        projectEntity.id = UUID()
        projectEntity.title = "我的新剪辑 \(DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .none))"
        projectEntity.creationDate = Date()
        projectEntity.lastModifiedDate = Date()
        self.currentProjectEntity = projectEntity

        // 2. 处理第一个媒体资源 (这会保存视频、生成缩略图并创建 MediaAssetEntity)
        addMediaAssetToCurrentProject(videoURL: videoURL, isFirstAssetInProject: true)

        // 3. 创建 ProjectItem (SQLite, 用于列表)
        // 修正：projectEntity.objectID.uriRepresentation().absoluteString 返回非可选 String
        let projectEntityIDString = projectEntity.objectID.uriRepresentation().absoluteString
        
        // 设置 ProjectEntity 的 coverImagePath 为第一个媒体资源的缩略图文件名（如果成功生成）
        if let firstAsset = projectEntity.mediaAssets.firstObject as? MediaAssetEntity {
            // 缩略图文件名是基于 MediaAssetEntity.id 构建的
            projectEntity.coverImagePath = "\(firstAsset.id.uuidString)_thumb.jpg"
        }

        let newDraftProjectItem = ProjectItem(
            id: projectEntity.id?.uuidString ?? UUID().uuidString, // 将 UUID 转换为 String
            title: projectEntity.title,
            status: .draft,
            coverImagePath: projectEntity.coverImagePath, // 使用 ProjectEntity 的封面图路径
            projectFilePath: projectEntityIDString,
            duration: getVideoDuration(from: videoURL)
        )
        self.currentDraftProjectItem = newDraftProjectItem

        do {
            _ = try ProjectDBHelper.shared.createProject(item: newDraftProjectItem)
            print("新的草稿 ProjectItem 已创建并保存到 SQLite。")
            try managedObjectContext.save() // 保存 ProjectEntity (包括 coverImagePath) 和 MediaAssetEntity
            print("ProjectEntity 和初始 MediaAssetEntity 已保存到 Core Data。")
        } catch {
            print("保存 ProjectItem (SQLite) 或 Core Data 实体失败: \(error.localizedDescription)")
            managedObjectContext.rollback() // 如果保存失败，回滚 Core Data更改
            // TODO: 向UI传播错误
        }
    }

    private func addMediaAssetToCurrentProject(videoURL: URL, isFirstAssetInProject: Bool) {
        guard let projectEntity = self.currentProjectEntity else {
            print("错误: currentProjectEntity 为空，无法添加媒体资源。")
            return
        }

        guard let savedVideoURL = saveVideoToDocuments(sourceURL: videoURL) else {
            print("无法保存视频到 Documents 目录")
            // TODO: Propagate error to UI
            return
        }

        let mediaAssetEntity = MediaAssetEntity(context: managedObjectContext)
        mediaAssetEntity.id = UUID()
        mediaAssetEntity.originalFilePath = savedVideoURL.path
        mediaAssetEntity.mediaTypeRawValue = MediaType.video.rawValue
        mediaAssetEntity.duration = getVideoDuration(from: savedVideoURL) ?? 0.0
        mediaAssetEntity.importDate = Date()
        
        let asset = AVURLAsset(url: savedVideoURL)
        if let track = asset.tracks(withMediaType: .video).first {
            let size = track.naturalSize.applying(track.preferredTransform)
            mediaAssetEntity.width = Int32(abs(size.width))
            mediaAssetEntity.height = Int32(abs(size.height))
        }
        
        // 生成并保存缩略图，文件名基于 MediaAssetEntity.id
        // 这个文件名不会存储在 MediaAssetEntity 中，而是按约定使用
        if let thumbnailImage = generateThumbnail(for: savedVideoURL) {
            _ = saveImageToDocumentsDirectory(image: thumbnailImage, specificName: "\(mediaAssetEntity.id.uuidString)_thumb.jpg")
        }
        
        projectEntity.addToMediaAssets(mediaAssetEntity)
        projectEntity.lastModifiedDate = Date()

        do {
            try managedObjectContext.save()
            print("MediaAssetEntity 已保存并关联到 ProjectEntity。")
            loadMediaAssetsForCurrentProject()

            if isFirstAssetInProject {
                setupPlayer(with: savedVideoURL)
                // 如果是第一个素材，并且 currentDraftProjectItem 已创建，
                // 确保 ProjectEntity 的 coverImagePath (已在 createNewProjectAndAddFirstMedia 中设置)
                // 也同步到 draftItem 的 coverImagePath (如果 draftItem 的 coverImagePath 之前是 nil)
                // 修正：直接修改 self.currentDraftProjectItem 的属性
                if self.currentDraftProjectItem?.coverImagePath == nil {
                    self.currentDraftProjectItem?.coverImagePath = projectEntity.coverImagePath
                    if let updatedDraftItem = self.currentDraftProjectItem { // 确保不为 nil 才更新数据库
                       try? ProjectDBHelper.shared.updateProject(item: updatedDraftItem)
                    }
                }
            }
            self.videoState = .videoLoaded

        } catch {
            print("保存 MediaAssetEntity 或更新 ProjectEntity 失败: \(error.localizedDescription)")
            managedObjectContext.rollback()
            // TODO: Propagate error to UI
        }
    }
    
    private func loadMediaAssetsForCurrentProject() {
        guard let projectEntity = self.currentProjectEntity,
              let assets = projectEntity.mediaAssets.array as? [MediaAssetEntity] else {
            self.mediaAssetsForDisplay = []
            return
        }
        
        self.mediaAssetsForDisplay = assets.compactMap { entity in
            var thumbImage: UIImage? = nil
            // 根据 MediaAssetEntity.id 构建缩略图文件名来加载
            let thumbnailFilename = "\(entity.id.uuidString)_thumb.jpg"
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let imageURL = documentsDirectory.appendingPathComponent(thumbnailFilename)
            
            if FileManager.default.fileExists(atPath: imageURL.path) {
                thumbImage = UIImage(contentsOfFile: imageURL.path)
            } else {
                print("缩略图未找到: \(thumbnailFilename)")
            }
            
            return MediaAssetDisplayViewModel(
                id: entity.id,
                thumbnail: thumbImage,
                durationString: formatTimeInterval(entity.duration)
            )
        }
    }

    private func getFirstMediaAssetURLFromCurrentProject() -> URL? {
        guard let firstAssetEntity = self.currentProjectEntity?.mediaAssets.firstObject as? MediaAssetEntity, // mediaAssets 是 NSOrderedSet
              let filePath = firstAssetEntity.originalFilePath else { // 使用 originalFilePath
            return nil
        }
        return URL(fileURLWithPath: filePath)
    }
    
    public func addSelectedMediaAssetToTimeline(assetID: UUID) {
        guard let project = self.currentProjectEntity else {
            print("Error: Current project entity is nil.")
            return
        }

        guard let mediaAsset = (project.mediaAssets.array as? [MediaAssetEntity])?.first(where: { $0.id == assetID }) else {
            print("Error: MediaAssetEntity with ID \(assetID) not found in current project.")
            return
        }

        guard let newClip = createClipEntity(from: mediaAsset) else {
            print("Error: Failed to create ClipEntity from MediaAsset.")
            return
        }

        guard let targetTrack = getDefaultTrack() else {
            print("Error: Failed to get or create a default track.")
            // Optionally, rollback newClip creation if it was added to context but not saved
            managedObjectContext.delete(newClip) // Example of cleanup
            return
        }

        addClip(newClip, to: targetTrack)

        project.lastModifiedDate = Date()
        do {
            try managedObjectContext.save()
            print("Successfully added clip to track and saved context.")
            print("current track , \(String(describing: project.tracks?.count)) , current clips \(String(describing: targetTrack.clips?.count))")
            // MARK: -Notify UI to refresh timeline display if necessary
            updatePlayerWithComposedTimeline()
            timelineNeedsUpdate.send()
        } catch {
            print("Error saving context after adding clip to track: \(error.localizedDescription)")
            // Rollback changes if save fails
            managedObjectContext.rollback()
        }
    }

    private func createClipEntity(from mediaAsset: MediaAssetEntity) -> ClipEntity? {
        let clipEntity = ClipEntity(context: managedObjectContext)
        clipEntity.id = UUID()
        clipEntity.mediaAsset = mediaAsset
        clipEntity.sourceDuration = mediaAsset.duration
        clipEntity.durationInTrack = mediaAsset.duration // Default to full duration
        clipEntity.startTimeInTrack = 0 // Will be set when added to a track
        clipEntity.isMuted = false
        clipEntity.playbackSpeed = 1.0
        clipEntity.volume = 1.0
        // Set other default properties as needed

        return clipEntity
    }

    private func getDefaultTrack() -> TrackEntity? {
        guard let project = self.currentProjectEntity else { return nil }

        if let tracks = project.tracks, tracks.count > 0, let firstTrack = tracks.object(at: 0) as? TrackEntity {
            // For now, return the first track.
            // A more robust implementation would search for a suitable video track
            // or allow user selection, or check trackTypeRawValue.
            return firstTrack
        } else {
            // No tracks exist, create a new one
            let newTrack = TrackEntity(context: managedObjectContext)
            newTrack.id = UUID()
            newTrack.trackIndex = 0 // First track
            newTrack.trackTypeRawValue = 0 // Assuming 0 is for a general/video track type
            newTrack.isMuted = false
            newTrack.isHidden = false
            newTrack.volume = 1.0
            
            project.addToTracks(newTrack) // Add to project's tracks
            // Note: The context needs to be saved after this for the change to persist.
            // The save will happen in addSelectedMediaAssetToTimeline.
            return newTrack
        }
    }

    private func addClip(_ clip: ClipEntity, to track: TrackEntity) {
        var startTime: Double = 0.0
        if let existingClips = track.clips, existingClips.count > 0 {
            if let lastClip = existingClips.lastObject as? ClipEntity {
                startTime = lastClip.startTimeInTrack + lastClip.durationInTrack
            }
        }
        
        clip.startTimeInTrack = startTime
        clip.track = track // Associate clip with the track
        
        // Add clip to the track's ordered set of clips
        // The NSOrderedSet generated accessors should handle this correctly.
        // track.addToClips(clip) or track.insertIntoClips(clip, at: track.clips?.count ?? 0)
        // Let's use the append-like accessor if available and suitable.
        // From TrackEntity+CoreDataProperties: @NSManaged public func addToClips(_ value: ClipEntity)
        track.addToClips(clip)
    }
    
    //更新player
    //MARK: -后续的播放源，不应该只有clips的media asset拼接而成
    private func updatePlayerWithComposedTimeline() {
        guard let project = currentProjectEntity,
              let firstTrack = project.tracks?.firstObject as? TrackEntity, // 简化：假设我们处理第一个轨道
              let clips = firstTrack.clips?.array as? [ClipEntity], // 确保 clips 是有序的
              !clips.isEmpty else {
            // 没有轨道或片段可播放，可能需要清除播放器或显示占位符
            self.player?.replaceCurrentItem(with: nil)
            // self.videoState = .noVideo // 或者其他合适的状态
            // Clear notifications if player item is nil
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
            return
        }

        let mutableComposition = AVMutableComposition()
        
        // 为视频和音频创建组合轨道
        guard let videoCompositionTrack = mutableComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
              let audioCompositionTrack = mutableComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
            print("无法创建组合轨道")
            return
        }

        var currentTimeInComposition = CMTime.zero

        for clipEntity in clips {
            guard let mediaAsset = clipEntity.mediaAsset,
                  let filePath = mediaAsset.originalFilePath else {
                print("片段 \(clipEntity.id?.uuidString ?? "未知") 缺少媒体资源或路径")
                continue
            }
            
            let assetURL = URL(fileURLWithPath: filePath)
            let sourceAsset = AVURLAsset(url: assetURL)
            
            // 定义要从源素材中提取的时间范围
            // 假设 clipEntity.sourceStartTime 和 clipEntity.durationInTrack 定义了片段在源素材中的具体部分和在时间线上的时长
            let timeRangeInSource = CMTimeRange(start: CMTime(seconds: clipEntity.sourceStartTime, preferredTimescale: 600),
                                                duration: CMTime(seconds: clipEntity.durationInTrack, preferredTimescale: 600))

            do {
                // 添加视频轨道部分
                if let sourceVideoTrack = sourceAsset.tracks(withMediaType: .video).first {
                    try videoCompositionTrack.insertTimeRange(timeRangeInSource,
                                                              of: sourceVideoTrack,
                                                              at: currentTimeInComposition)
                }
                // 添加音频轨道部分
                if let sourceAudioTrack = sourceAsset.tracks(withMediaType: .audio).first {
                    try audioCompositionTrack.insertTimeRange(timeRangeInSource,
                                                              of: sourceAudioTrack,
                                                              at: currentTimeInComposition)
                }
                
                // 更新下一个片段在组合中的开始时间
                currentTimeInComposition = CMTimeAdd(currentTimeInComposition, timeRangeInSource.duration)
                
            } catch {
                print("无法将片段 \(clipEntity.id?.uuidString ?? "未知") 添加到组合中: \(error)")
            }
        }
        
        if mutableComposition.tracks.isEmpty || mutableComposition.duration == .zero {
            print("组合为空或时长为零，不进行播放设置。")
            self.player?.replaceCurrentItem(with: nil)
            // Clear notifications if player item is nil
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
            return
        }

        let playerItem = AVPlayerItem(asset: mutableComposition)
        
        if self.player == nil {
            self.player = AVPlayer(playerItem: playerItem)
            let newPlayerLayer = AVPlayerLayer(player: self.player)
            newPlayerLayer.videoGravity = .resizeAspect
            self.playerLayer = newPlayerLayer
        } else {
           
            self.player?.replaceCurrentItem(with: playerItem)
        }
        
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        if let currentItem = self.player?.currentItem { // Add observer for the new current item
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(playerDidFinishPlayingNotification),
                                                   name: .AVPlayerItemDidPlayToEndTime,
                                                   object: currentItem)
        }

    }
    
    private func setupPlayer(with videoURL: URL) {
        player = AVPlayer(url: videoURL)
        let newPlayerLayer = AVPlayerLayer(player: player)
        newPlayerLayer.videoGravity = .resizeAspect
        self.playerLayer = newPlayerLayer // This will publish the change

        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlayingNotification),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: player?.currentItem)
    
    }

    // MARK: - Playback Controls
    func togglePlayPause() {
        guard player != nil else { return }

        if player?.rate == 0 { // Paused or stopped
            player?.play()
            isPlaying = true
        } else { // Playing
            player?.pause()
            isPlaying = false
        }
    }

    @objc private func playerDidFinishPlayingNotification(_ notification: Notification) {
        player?.seek(to: .zero)
        isPlaying = false
        // If you need to notify UI to update play/pause button state,
        // the @Published isPlaying property handles this if observed.
    }
    
    func seek(to time: CMTime) {
        player?.seek(to: time)
    }

    // MARK: - File Operations (Should be private or internal)
    private func saveVideoToDocuments(sourceURL: URL) -> URL? {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileName = UUID().uuidString + "." + sourceURL.pathExtension
        let destinationURL = documentsDirectory.appendingPathComponent(fileName)
        
        do {
            if fileManager.fileExists(atPath: destinationURL.path) {
                try fileManager.removeItem(at: destinationURL)
            }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
            print("视频已保存到: \(destinationURL.path)")
            return destinationURL
        } catch {
            print("保存视频失败: \(error)")
            return nil
        }
    }
    
    // 新增/恢复: 生成视频缩略图的函数
    private func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        // 获取视频第1秒的帧作为缩略图，如果视频太短，则取第0秒
        var time = CMTime(seconds: 1, preferredTimescale: 600)
        if asset.duration.seconds < 1 {
            time = CMTime(seconds: 0, preferredTimescale: 600)
        }
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            print("生成缩略图失败 for \(url.lastPathComponent): \(error.localizedDescription)")
            // 尝试获取第0帧作为备选
            do {
                let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
                return UIImage(cgImage: cgImage)
            } catch {
                print("再次尝试生成缩略图 (0s) 失败 for \(url.lastPathComponent): \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    private func saveImageToDocumentsDirectory(image: UIImage, specificName: String? = nil) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            print("无法将图片转换为JPEG数据")
            return nil
        }
        
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileName = specificName ?? (UUID().uuidString + ".jpg")
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                print("图片已保存到: \(fileURL.path)")
                return fileName
            } catch {
                print("保存图片失败: \(error)")
                return nil
            }
        }
        return nil
    }
    
    private func getVideoDuration(from url: URL) -> TimeInterval? {
        let asset = AVURLAsset(url: url)
        let duration = asset.duration
        return CMTimeGetSeconds(duration)
    }
    
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: interval) ?? "0:00"
    }
}

