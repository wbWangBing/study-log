import UIKit

class TemplateHeaderView: UICollectionReusableView {
    
    // MARK: - 1. 顶部Tab（模板/灵感）和一键成片
    private let titleTabs = ["模板", "灵感"]
    private var titleButtons: [UIButton] = []
    
    let quickCreateButton: UIButton = {
        let button = UIButton() 

        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "quickcreat_icon")?.withRenderingMode(.alwaysTemplate)
        let title = "一键成片"
        var attributedTitle = AttributedString(title)
        attributedTitle.font = UIFont.systemFont(ofSize: 12)
        config.attributedTitle = attributedTitle
        
        config.imagePlacement = .top 
        config.imagePadding = 4      

        config.baseForegroundColor = .white // 设置图标和文字颜色为白色

        config.background.backgroundColor = .clear 
        config.cornerStyle = .medium

        button.configuration = config
        
        return button
    }()
    
    // MARK: - 2. 搜索栏
    let searchBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.15, alpha: 1)
        view.layer.cornerRadius = 18
        return view
    }()
    let searchIcon: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        imageView.tintColor = .gray
        return imageView
    }()
    let searchTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "亲吻屏幕转场"
        tf.font = UIFont.systemFont(ofSize: 15)
        tf.textColor = .white
        tf.backgroundColor = .clear
        return tf
    }()
    let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("搜索", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        return button
    }()
    
    // MARK: - 3. 二级Tab栏（热门/营销）
    private let secondTabs = ["热门", "营销"]
    private var secondTabButtons: [UIButton] = []
    private let secondTabUnderline = UIView()
    
    // MARK: - 4. 推荐标签栏和筛选按钮
    let tagScrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.showsHorizontalScrollIndicator = false
        return scroll
    }()
    let tags = ["推荐", "创意AI🔥", "爱用", "Live实况", "春"]
    private var tagButtons: [UIButton] = []
    let filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "slider.horizontal.3"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        return button
    }()
    
    // MARK: - 回调
    var onTopTabChanged: ((Int) -> Void)?
    var onSecondTabChanged: ((Int) -> Void)?
    var onTagChanged: ((Int) -> Void)?
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        
        // 1. 顶部Tab
        for (i, tab) in titleTabs.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(tab, for: .normal)
            // Initial colors and font will be set in layoutSubviews based on selection state
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 28) // Set base font size
            btn.tag = i
            btn.addTarget(self, action: #selector(topTabTapped(_:)), for: .touchUpInside)
            btn.tintColor = .clear
            if i == 0 { // Select the first tab by default
                btn.isSelected = true
            }
            titleButtons.append(btn)
            addSubview(btn)
        }
 
        addSubview(quickCreateButton)
        
        // 2. 搜索栏
        addSubview(searchBackground)
        searchBackground.addSubview(searchIcon)
        searchBackground.addSubview(searchTextField)
        searchBackground.addSubview(searchButton)
        
        // 3. 二级Tab
        for (i, tab) in secondTabs.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(tab, for: .normal)
            btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
            btn.tag = i
            btn.addTarget(self, action: #selector(secondTabTapped(_:)), for: .touchUpInside)
            btn.tintColor = .clear
            btn.isSelected = (i == 0)
            secondTabButtons.append(btn)
            addSubview(btn)
        }
        secondTabUnderline.backgroundColor = .systemRed
        secondTabUnderline.layer.cornerRadius = 1.5
        addSubview(secondTabUnderline)
        
        // 4. 推荐标签和筛选按钮
        addSubview(tagScrollView)
        for (i, tag) in tags.enumerated() {
            let btn = UIButton(type: .system)
            btn.setTitle(tag, for: .normal)
            btn.setTitleColor(i == 0 ? .white : .gray, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            btn.backgroundColor = .clear
            btn.tag = i
            btn.addTarget(self, action: #selector(tagTapped(_:)), for: .touchUpInside)
            tagButtons.append(btn)
            tagScrollView.addSubview(btn)
        }
        addSubview(filterButton)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 布局
    override func layoutSubviews() {
        super.layoutSubviews()
        let width = bounds.width
        var y: CGFloat = 4
        
        // 1. 顶部Tab
        var x: CGFloat = 16
        let originalFontSize: CGFloat = 20
        let selectedFontSize: CGFloat = originalFontSize * 1.1 // Slightly smaller magnification to ensure visibility, adjust as needed
        let buttonHeight: CGFloat = 18 // Ensure enough height for magnified font

        for btn in titleButtons {
            if btn.isSelected {
                btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: selectedFontSize)
                btn.setTitleColor(.white, for: .normal)
                btn.setTitleColor(.white, for: .selected) // <--- 为选中状态添加这行
            } else {
                btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: originalFontSize)
                btn.setTitleColor(.gray, for: .normal)
            }
            btn.backgroundColor = .clear // Ensure background is clear

            // Calculate width based on current font and add padding
            let btnWidth = btn.intrinsicContentSize.width + 16 // e.g., 8 points padding on each side
            btn.frame = CGRect(x: x, y: y, width: btnWidth, height: buttonHeight)
            x += btnWidth + 16 // Spacing between buttons
        }
        
        y += 44
        
        quickCreateButton.frame = CGRect(x: width - 100, y: y, width: 80, height: 46) // Adjust y if buttonHeight changed significantly
       
        // 2. 搜索栏
        searchBackground.frame = CGRect(x: 16, y: y, width: width - 112, height: 40)
        searchIcon.frame = CGRect(x: 12, y: 8, width: 20, height: 20)
        searchTextField.frame = CGRect(x: 40, y: 0, width: searchBackground.frame.width - 100, height: 40)
        searchButton.frame = CGRect(x: searchBackground.frame.width - 48, y: 0, width: 48, height: 40)
        y += 44
        
        // 3. 二级Tab栏
        var secondTabX: CGFloat = 16
        
        for (_, btn) in secondTabButtons.enumerated() {
            let btnWidth = btn.intrinsicContentSize.width + 8
            btn.frame = CGRect(x: secondTabX, y: y, width: btnWidth, height: 28)
            if btn.isSelected {
                btn.setTitleColor(.white, for: .normal)
                btn.setTitleColor(.white, for: .selected)
            } else {
                btn.setTitleColor(.gray, for: .normal)
            }
            secondTabX += btnWidth + 24
        }
        if let selected = secondTabButtons.first(where: { $0.isSelected }) ?? secondTabButtons.first {
            let underlineWidth = selected.intrinsicContentSize.width
            secondTabUnderline.frame = CGRect(
                x: selected.frame.minX + 4,
                y: selected.frame.maxY - 2,
                width: underlineWidth,
                height: 3
            )
        }
        y += 34
        
        // 4. 推荐标签栏
        tagScrollView.frame = CGRect(x: 16, y: y, width: width - 64, height: 32)
        var tagX: CGFloat = 0
        for btn in tagButtons {
            let btnWidth = btn.intrinsicContentSize.width + 24
            btn.frame = CGRect(x: tagX, y: 0, width: btnWidth, height: 28)
            tagX += btnWidth + 8
        }
        tagScrollView.contentSize = CGSize(width: tagX, height: 32)
        filterButton.frame = CGRect(x: width - 40, y: y, width: 28, height: 28)
        // header总高度建议：y + 32 + 8
    }
    
    // MARK: - 交互
    @objc private func topTabTapped(_ sender: UIButton) {
        for (i, btn) in titleButtons.enumerated() {
            btn.isSelected = (i == sender.tag)
        }
        // No need to set colors or font here, layoutSubviews will handle it
        setNeedsLayout() // Trigger layoutSubviews to update appearance and frames
        onTopTabChanged?(sender.tag)
    }
    
    @objc private func secondTabTapped(_ sender: UIButton) {
        for (i, btn) in secondTabButtons.enumerated() {
            btn.setTitleColor(i == sender.tag ? .white : .gray, for: .normal)
            btn.isSelected = (i == sender.tag)
        }
        setNeedsLayout()
        onSecondTabChanged?(sender.tag)
    }
    
    @objc private func tagTapped(_ sender: UIButton) {
        for (i, btn) in tagButtons.enumerated() {
            btn.setTitleColor(i == sender.tag ? .white : .gray, for: .normal)
        }
        onTagChanged?(sender.tag)
    }
    
    // MARK: - 外部方法
    static func headerTotalHeight() -> CGFloat {
        // 返回当前header的总高度，便于外部设置collectionView的section header高度
        // 44(大标题) + 44(搜索) + 34(二级tab) + 32(标签) + 8(底部间距)
        return 4 + 44 + 44 + 34 + 32 + 8
    }
}

