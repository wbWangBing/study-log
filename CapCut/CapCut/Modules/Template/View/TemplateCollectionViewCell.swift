import UIKit

class TemplateCollectionViewCell: UICollectionViewCell {
    static let identifier = "TemplateCollectionViewCell"
    
    // MARK: - UI元素
    let coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        return imageView
    }()
    
    let nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    let hotLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        label.textAlignment = .right
        return label
    }()
    
    // MARK: - 属性
    private var coverImageHeight: CGFloat = 0
    
    // MARK: - 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.black
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        
        contentView.addSubview(coverImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(avatarImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(hotLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 动态布局
    override func layoutSubviews() {
        super.layoutSubviews()
        let padding: CGFloat = 8
        let avatarSize: CGFloat = 20
        let titleHeight: CGFloat = 26
        
        let coverWidth = contentView.bounds.width - 2 * padding
        let coverHeight = coverImageHeight
        
        coverImageView.frame = CGRect(x: 0, y: 0, width: coverWidth +  2 * padding, height: coverHeight)
        titleLabel.frame = CGRect(x: padding, y: coverImageView.frame.maxY + 2, width: coverWidth, height: titleHeight)
        avatarImageView.frame = CGRect(x: padding, y: titleLabel.frame.maxY + 2, width: avatarSize, height: avatarSize)
        nicknameLabel.frame = CGRect(x: avatarImageView.frame.maxX + 4, y: avatarImageView.frame.minY, width: 60, height: avatarSize)
        hotLabel.frame = CGRect(x: nicknameLabel.frame.maxX + 4, y: avatarImageView.frame.minY, width: coverWidth - (avatarSize + 4 + 60 + 4), height: avatarSize)
    }
    
    // MARK: - 配置数据
    /// 你需要在外部（比如cellForItemAt）传入图片等比缩放后的高度
    func configure(with model: TemplateModel, coverImageHeight: CGFloat) {
        coverImageView.image = UIImage(named: model.coverImageName)
        titleLabel.text = model.title
        avatarImageView.image = UIImage(named: model.avatarImageName)
        nicknameLabel.text = model.nickname
        hotLabel.text = model.hotText
        self.coverImageHeight = coverImageHeight
        setNeedsLayout()
    }
}
