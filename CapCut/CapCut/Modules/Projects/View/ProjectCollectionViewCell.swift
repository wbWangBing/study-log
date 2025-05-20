//
//  ProjectCollectionViewCell.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/13.
//

import UIKit

class ProjectCollectionViewCell: UICollectionViewCell {
    static let identifier = "ProjectCollectionViewCell"

    private let thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill // 填充整个区域
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray // 占位背景色
        imageView.layer.cornerRadius = 8 // 轻微的圆角
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = { // 添加 titleLabel
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .white
        // 为标题添加一点背景或阴影使其在各种图片上都可见
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowRadius = 3.0
        label.layer.shadowOpacity = 0.8
        label.layer.shadowOffset = CGSize(width: 1, height: 1)
        label.layer.masksToBounds = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel) // 将 titleLabel 添加到 contentView
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            thumbnailImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            // titleLabel 约束 (位于左下角)
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -8), // 避免超出
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
    }

    public func configure(with project: ProjectItem) {
        titleLabel.text = project.title // 设置标题

        // 尝试加载封面图片
        if let imageName = project.coverImagePath, !imageName.isEmpty { // imageName 现在存储的是文件名
            let fileManager = FileManager.default
            // 获取 Documents 目录 URL
            if let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                // 拼接文件名以创建完整的文件 URL
                let imageFileURL = documentsDirectoryURL.appendingPathComponent(imageName)
                
                // 尝试从文件 URL 加载图片
                if FileManager.default.fileExists(atPath: imageFileURL.path), let localImage = UIImage(contentsOfFile: imageFileURL.path) {
                    thumbnailImageView.image = localImage
                    thumbnailImageView.backgroundColor = .clear // 清除占位背景色
                } else {
                    // 如果加载失败，打印错误并设置占位符
                    print("无法从 reconstructed 路径加载图片: \(project.title), \(imageFileURL.path). 文件是否存在: \(FileManager.default.fileExists(atPath: imageFileURL.path)). 将使用占位符。")
                    setPlaceholderImage(for: project.status)
                }
            } else {
                // 如果无法访问 Documents 目录，打印错误并设置占位符
                print("无法访问 Documents 目录. 将使用占位符。")
                setPlaceholderImage(for: project.status)
            }
        } else {
            // 没有存储封面图片路径，设置占位符
            setPlaceholderImage(for: project.status)
        }
    }
    
    private func setPlaceholderImage(for status: ItemStatus) {
        if status == .draft {
            thumbnailImageView.image = UIImage(systemName: "doc.text.image") // 草稿图标
            thumbnailImageView.backgroundColor = .systemOrange.withAlphaComponent(0.3)
        } else {
            thumbnailImageView.image = UIImage(systemName: "film") // 项目图标
            thumbnailImageView.backgroundColor = .systemBlue.withAlphaComponent(0.3)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil // 重置图片
        thumbnailImageView.backgroundColor = .lightGray // 重置背景色
        titleLabel.text = nil // 重置标题
    }
}
