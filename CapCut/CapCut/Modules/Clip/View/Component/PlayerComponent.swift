//
//  PlayerComponent.swift
//  CapCut
//
//  Created by WangBin on 2025/5/14.
//

import UIKit
import AVFoundation
import Combine // 引入 Combine 用于可能的 ViewModel 绑定

// 建议在 ClipViewModel 中定义一个用于显示的结构体/类, 或者一个共享文件
// 这里先定义一个临时的，后续可以移到 ViewModel 或共享模型中
struct MediaAssetDisplayViewModel {
    let id: UUID // 或者 NSManagedObjectID
    let thumbnail: UIImage?
    let durationString: String?
    // 可以添加更多用于显示的属性
}

class PlayerComponent: UIView {
    // MARK: - Properties
    private let viewModel: ClipViewModel
    private var cancellables = Set<AnyCancellable>() // 用于 Combine 订阅

    var playerLayer: AVPlayerLayer? {
        didSet {
            oldValue?.removeFromSuperlayer()
            if let newLayer = playerLayer {
                layer.addSublayer(newLayer)
                newLayer.frame = bounds // 确保新 layer 立即有正确的 frame
                setNeedsLayout() // 触发 layoutSubviews
            }
        }
    }

    private lazy var startCreatingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
        view.layer.cornerRadius = 12
        view.clipsToBounds = true

        let plusImageView = UIImageView(image: UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 50, weight: .light)))
        plusImageView.tintColor = .lightGray
        plusImageView.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = UILabel()
        titleLabel.text = "开始创作"
        titleLabel.textColor = .lightGray
        titleLabel.font = .systemFont(ofSize: 18, weight: .medium)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [plusImageView, titleLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        // target/action 由 ClipViewController 设置
        return view
    }()

    // 新增：用于展示项目媒体资源的 CollectionView
    private lazy var mediaAssetsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 60, height: 60)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MediaAssetCell.self, forCellWithReuseIdentifier: MediaAssetCell.reuseIdentifier)
        collectionView.isHidden = true // 初始隐藏
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) // 给左右一些边距
        return collectionView
    }()

    // MARK: - Initialization
    init(frame: CGRect = .zero, viewModel: ClipViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setupUI()
        showStartCreatingView(viewModel.videoState == .noVideo) // 根据 ViewModel 初始状态设置
        bindViewModel() // 绑定 ViewModel 的媒体资源更新
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
        // 确保 startCreatingView 和 mediaAssetsCollectionView 在 playerLayer 之上
        bringSubviewToFront(startCreatingView)
        bringSubviewToFront(mediaAssetsCollectionView)
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .black
        addSubview(startCreatingView)
        addSubview(mediaAssetsCollectionView) // 添加 CollectionView
        
        NSLayoutConstraint.activate([
            startCreatingView.centerXAnchor.constraint(equalTo: centerXAnchor),
            startCreatingView.centerYAnchor.constraint(equalTo: centerYAnchor),
            startCreatingView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
            startCreatingView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),

            // mediaAssetsCollectionView 约束 (示例：底部，左右有边距)
            mediaAssetsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mediaAssetsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mediaAssetsCollectionView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -10),
            mediaAssetsCollectionView.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        // 监听 ViewModel 中用于显示的媒体资源数组的变化
        viewModel.$mediaAssetsForDisplay
            .receive(on: DispatchQueue.main)
            .sink { [weak self] assets in
                guard let self = self else { return }
                self.mediaAssetsCollectionView.reloadData()
                // 当有视频加载（即不再是 noVideo 状态）并且有媒体资源时，显示 collectionView
                let shouldShowCollectionView = self.viewModel.videoState == .videoLoaded && !assets.isEmpty
                self.mediaAssetsCollectionView.isHidden = !shouldShowCollectionView
                
                // 如果 videoState 是 noVideo，即使 assets 变化了，也应该隐藏 collectionView
                if self.viewModel.videoState == .noVideo {
                    self.mediaAssetsCollectionView.isHidden = true
                }
            }
            .store(in: &cancellables)

        // 监听 videoState 的变化，以确保在没有视频时隐藏媒体资源集合
        viewModel.$videoState
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                if state == .noVideo {
                    self.mediaAssetsCollectionView.isHidden = true
                    self.showStartCreatingView(true)
                } else {
                    // 当视频加载后，根据是否有媒体资源来决定是否显示 collectionView
                    self.mediaAssetsCollectionView.isHidden = self.viewModel.mediaAssetsForDisplay.isEmpty
                    self.showStartCreatingView(false)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Public Methods
    // configure 方法可以移除，因为 viewModel 是在 init 时传入的
    // func configure(viewModel: ClipViewModel) {}
    
    func showStartCreatingView(_ show: Bool) {
        startCreatingView.isHidden = !show
        // 如果 startCreatingView 显示，则 mediaAssetsCollectionView 应该隐藏
        if show {
            mediaAssetsCollectionView.isHidden = true
        }
    }
    
    func addStartCreatingGesture(_ target: Any?, action: Selector) {
        let tapGesture = UITapGestureRecognizer(target: target, action: action)
        startCreatingView.addGestureRecognizer(tapGesture)
        startCreatingView.isUserInteractionEnabled = true
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension PlayerComponent: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.mediaAssetsForDisplay.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MediaAssetCell.reuseIdentifier, for: indexPath) as? MediaAssetCell else {
            fatalError("Unable to dequeue MediaAssetCell")
        }
        let assetViewModel = viewModel.mediaAssetsForDisplay[indexPath.item]
        cell.configure(with: assetViewModel)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAssetViewModel = viewModel.mediaAssetsForDisplay[indexPath.item]
        print("选择了素材: \(selectedAssetViewModel.id)")
        // 通知 ViewModel 媒体资源被选中，ViewModel 可以决定如何处理，例如将其添加到时间线
         viewModel.addSelectedMediaAssetToTimeline(assetID: selectedAssetViewModel.id)
    }
}

// MARK: - MediaAssetCell
// 将 MediaAssetCell 定义在 PlayerComponent.swift 文件底部
class MediaAssetCell: UICollectionViewCell {
    static let reuseIdentifier = "MediaAssetCell"
    
    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = .darkGray // 占位背景色
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textAlignment = .right
        label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        // 给label一点内边距
        label.textInsets = UIEdgeInsets(top: 1, left: 3, bottom: 1, right: 3)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(durationLabel)
        contentView.backgroundColor = .clear // Cell 背景透明
        contentView.layer.cornerRadius = 6
        contentView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            durationLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            durationLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with assetViewModel: MediaAssetDisplayViewModel) {
        thumbnailImageView.image = assetViewModel.thumbnail ?? UIImage(systemName: "film") // 使用一个默认图标
        durationLabel.text = assetViewModel.durationString ?? "0:00"
        durationLabel.isHidden = assetViewModel.durationString == nil
    }
}

// 为了让 UILabel 支持内边距，可以扩展 UILabel
extension UILabel {
    private struct AssociatedKeys {
        static var padding = "padding"
    }

    public var textInsets: UIEdgeInsets? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.padding) as? UIEdgeInsets
        }
        set {
            if let newValue = newValue {
                objc_setAssociatedObject(self, &AssociatedKeys.padding, newValue as UIEdgeInsets?, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }



    override open var intrinsicContentSize: CGSize {
        guard let text = self.text else { return super.intrinsicContentSize }
        var contentSize = super.intrinsicContentSize
        if let insets = textInsets {
            contentSize.height += insets.top + insets.bottom
            contentSize.width += insets.left + insets.right
        }
        return contentSize
    }
}
