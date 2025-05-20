//
//  TimelineComponent.swift
//  CapCut
//
//  Created by WangBin on 2025/5/14.
//

import UIKit
import Combine // 导入 Combine

// 临时的 ClipTimelineCell 定义，后续可以移到单独文件并完善
fileprivate class ClipTimelineCell: UICollectionViewCell {
    static let reuseIdentifier = "ClipTimelineCell"
    let imageView: UIImageView = { // 改为 UIImageView
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill // 图片填充方式
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemGray // 可以设置一个背景色以防图片加载失败
        contentView.layer.cornerRadius = 4
        contentView.layer.masksToBounds = true

        contentView.addSubview(imageView) // 添加 imageView

        NSLayoutConstraint.activate([
            //让 imageView 填充满整个 cell
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage?) { // 修改 configure 方法接收 UIImage
        if let img = image {
            imageView.image = img
            imageView.backgroundColor = .clear // 有图片时清除背景色
        } else {
            imageView.image = nil // 没有图片则清空
            imageView.backgroundColor = .darkGray // 或显示一个占位符颜色/图标
        }
    }
}


class TimelineComponent: UIView {
    // MARK: - Properties
    private let viewModel: ClipViewModel
    private var cancellables = Set<AnyCancellable>() // 用于 Combine 订阅

    lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "play.fill"), for: .normal)
        button.tintColor = .darkGray
        button.translatesAutoresizingMaskIntoConstraints = false
        // target/action 需要由 ClipViewController 设置
        button.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        button.isEnabled = false // 初始禁用
        return button
    }()
    private lazy var clipsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        // sectionInset可以根据需要调整
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .darkGray // 时间轴背景色
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ClipTimelineCell.self, forCellWithReuseIdentifier: ClipTimelineCell.reuseIdentifier)
        collectionView.showsHorizontalScrollIndicator = true
        return collectionView
    }()

    // MARK: - Initialization
    init(frame: CGRect = .zero, viewModel: ClipViewModel) { // 修改 init
        self.viewModel = viewModel // 存储 viewModel
        super.init(frame: frame)
        setupUI()
        setupBindings() // 设置 Combine 订阅
        updatePlayPauseButton(isPlaying: viewModel.isPlaying, isEnabled: viewModel.videoState == .videoLoaded)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .lightGray // TimelineComponent 自身的背景色
        // 移除旧的 placeholderLabel
        // addSubview(timelinePlaceholderLabel) 
        addSubview(clipsCollectionView)
        addSubview(playPauseButton)
        
        NSLayoutConstraint.activate([
            // clipsCollectionView 占据大部分空间
            clipsCollectionView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            clipsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            clipsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            clipsCollectionView.heightAnchor.constraint(equalToConstant: 80), // 可调整时间轴高度

            // playPauseButton 放在 clipsCollectionView 下方居中
            playPauseButton.topAnchor.constraint(equalTo: clipsCollectionView.bottomAnchor, constant: 10),
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 36),
            playPauseButton.heightAnchor.constraint(equalToConstant: 36),
            
            // 确保 TimelineComponent 的底部至少延伸到播放按钮下方
            playPauseButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -10)
        ])
    }

    private func setupBindings() {
        // 订阅 viewModel 中 isPlaying 和 videoState 的变化来更新播放按钮
        viewModel.$isPlaying
            .combineLatest(viewModel.$videoState)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isPlaying, videoState in
                self?.updatePlayPauseButton(isPlaying: isPlaying, isEnabled: videoState == .videoLoaded)
            }
            .store(in: &cancellables)

        // 订阅 viewModel 中 timelineNeedsUpdate 信号来刷新 collectionView
        // 注意: timelineNeedsUpdate 需要在 ClipViewModel 中定义
        viewModel.timelineNeedsUpdate // 假设 viewModel 有这个 Publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                print("TimelineComponent: Received timelineNeedsUpdate signal. Reloading collection view.")
                self?.clipsCollectionView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func configure(viewModel: ClipViewModel) {
        // self.viewModel = viewModel
        // 可以在这里观察 viewModel 的状态来更新 UI
    }
    
    func updatePlayPauseButton(isPlaying: Bool, isEnabled: Bool) {
        playPauseButton.setImage(UIImage(systemName: isPlaying ? "pause.fill" : "play.fill"), for: .normal)
        playPauseButton.isEnabled = isEnabled
    }
    
    func addPlayPauseButtonTarget(_ target: Any?, action: Selector) {
        playPauseButton.addTarget(target, action: action, for: .touchUpInside)
    }
}

// MARK: - UICollectionViewDataSource
extension TimelineComponent: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 简化：假设我们只显示第一个轨道的片段
        guard let project = viewModel.currentProjectEntity,
              let firstTrack = project.tracks?.firstObject as? TrackEntity else {
            return 0
        }
        return firstTrack.clips?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ClipTimelineCell.reuseIdentifier, for: indexPath) as? ClipTimelineCell else {
            fatalError("Unable to dequeue ClipTimelineCell")
        }

        // 获取对应的 ClipEntity
        if let project = viewModel.currentProjectEntity,
           let firstTrack = project.tracks?.firstObject as? TrackEntity,
           let clips = firstTrack.clips?.array as? [ClipEntity],
           indexPath.item < clips.count {
            let clipEntity = clips[indexPath.item]
            
            var thumbnailImage: UIImage? = nil
            if let mediaAsset = clipEntity.mediaAsset { // 通过 ClipEntity 获取 MediaAssetEntity
                // 根据 MediaAssetEntity.id 构建缩略图文件名来加载
                let thumbnailFilename = "\(mediaAsset.id.uuidString)_thumb.jpg"
                if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let imageURL = documentsDirectory.appendingPathComponent(thumbnailFilename)
                    
                    if FileManager.default.fileExists(atPath: imageURL.path) {
                        thumbnailImage = UIImage(contentsOfFile: imageURL.path)
                    } else {
                        print("TimelineComponent: 缩略图未找到: \(thumbnailFilename)")
                    }
                }
            }
            cell.configure(with: thumbnailImage) // 使用加载到的图片配置 cell
        } else {
            cell.configure(with: nil) // 数据异常，配置为空状态
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TimelineComponent: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 简化：所有片段暂时给一个固定宽度，高度撑满 sectionInset 后的可用空间
        // 将来可以根据片段时长动态计算宽度
        let availableHeight = collectionView.bounds.height - 20 // 减去 top 和 bottom sectionInset
        return CGSize(width: 60, height: max(0, availableHeight)) // 宽度可调整
    }
}
