//
//  ProfileHeaderView.swift
//  CapCut
//
//  Created by WangBin on 2025/5/12.
//

import UIKit

class ProfileHeaderView: UIView {

    // MARK: - 子控件
    let avatarImageView = UIImageView()
    let nicknameLabel = UILabel()
    let descLabel = UILabel()

    // 点击回调
    var onTap: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGesture()
    }

    private func setupUI() {
        backgroundColor = .clear

        // 头像
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 32
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.image = UIImage(named: "avatar4") // 默认头像
        avatarImageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        avatarImageView.heightAnchor.constraint(equalToConstant: 64).isActive = true

        // 昵称
        nicknameLabel.font = .boldSystemFont(ofSize: 18)
        nicknameLabel.textAlignment = .left
        nicknameLabel.text = "昵称"

        // 标签
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.textColor = .gray
        descLabel.textAlignment = .left
        descLabel.text = "标签"

        // 垂直StackView（昵称+标签）
        let vStack = UIStackView(arrangedSubviews: [nicknameLabel, descLabel])
        vStack.axis = .vertical
        vStack.spacing = 4
        vStack.alignment = .leading

        // 水平StackView（头像+右侧信息）
        let hStack = UIStackView(arrangedSubviews: [avatarImageView, vStack])
        hStack.axis = .horizontal
        hStack.spacing = 16
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(hStack)

        // 布局
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: topAnchor),
            hStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            hStack.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(headerTapped))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tap)
    }

    @objc private func headerTapped() {
        onTap?()
    }

    // MARK: - 外部设置数据
    func configure(avatar: UIImage?, nickname: String, desc: String) {
        if let avatar = avatar {
            avatarImageView.image = avatar
        }
        nicknameLabel.text = nickname
        descLabel.text = desc
    }
}

