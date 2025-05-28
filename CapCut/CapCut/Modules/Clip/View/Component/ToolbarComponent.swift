//
//  ToolbarComponent.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/14.
//

import UIKit

class ToolbarComponent: UIView {
    // MARK: - Properties
    private let viewModel: ClipViewModel
    var onAddMediaButtonTapped: (() -> Void)? // 新增：用于回调的闭包

    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "工具栏区"
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var addMediaButton: UIButton = { // 新增按钮
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        button.setTitle(" 添加素材", for: .normal) // 在文字前加一个空格，使其与图标有间隔
        button.tintColor = .systemBlue
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapAddMediaButtonAction), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Initialization
     init(frame: CGRect = .zero, viewModel: ClipViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .systemGray5
        addSubview(placeholderLabel)
        addSubview(addMediaButton) // 将新按钮添加到视图中
        
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            placeholderLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -20), // 向上移动一点为按钮腾出空间

            addMediaButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            addMediaButton.topAnchor.constraint(equalTo: placeholderLabel.bottomAnchor, constant: 10), // 按钮在标签下方
            addMediaButton.heightAnchor.constraint(equalToConstant: 44) // 给按钮一个合适的高度
        ])
    }

    // MARK: - Actions
    @objc private func didTapAddMediaButtonAction() { // 新增按钮的动作方法
        onAddMediaButtonTapped?() // 调用闭包，通知外部（ClipViewController）
    }

    // MARK: - Public Methods
    func configure(viewModel: ClipViewModel) {
        // self.viewModel = viewModel // viewModel 已在 init 时注入
        // 可以在这里观察 viewModel 的状态来更新 UI，如果需要的话
    }
}
