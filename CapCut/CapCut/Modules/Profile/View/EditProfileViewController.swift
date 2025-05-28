//
//  EditProfileViewController.swift
//  CapCut
//
//  Created by WangBin on 2025/5/12.
//

import UIKit

protocol EditProfileDelegate: AnyObject {
    func didUpdateProfile(_ profile: ProfileModel)
}

class EditProfileViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    private var profile: ProfileModel
    weak var delegate: EditProfileDelegate?
    
    init(profile: ProfileModel) {
        self.profile = profile
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI控件
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let avatarImageView = UIImageView()
    private let changeAvatarButton = UIButton(type: .system)

    private let nicknameField = UITextField()
    private let genderControl = UISegmentedControl(items: ["男", "女"])
    private let birthdayPicker = UIDatePicker()
    private let tagField = UITextField()
    private let ageLabel = UILabel()
    private let addressField = UITextField()
    private let schoolField = UITextField()
    private let saveButton = UIButton(type: .system)

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "编辑资料"
        setupUI()
        bindDataToUI()
    }
    
    //MARK: -图像选择代理协议实现
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        // 获取图片
        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        guard let selectedImage = image else { return }

        // 显示到UI
        avatarImageView.image = selectedImage

        // 保存到沙盒
        if let path = saveImageToDocuments(selectedImage) {
            profile.avatarPath = path
        }
    }

    // 取消选择
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    // MARK: - 数据绑定
    private func bindDataToUI() {
        // 头像
        if let image = loadImage(from: profile.avatarPath) {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(named: "avatar4")
        }
        // 昵称
        nicknameField.text = profile.nickname
        // 性别
        genderControl.selectedSegmentIndex = (profile.gender == "女") ? 1 : 0
        // 生日
        birthdayPicker.date = profile.birthday
        // 标签
        tagField.text = profile.description
        // 年龄
        ageLabel.text = "年龄：\(profile.age)"
        // 地址
        addressField.text = profile.address
        // 学校
        schoolField.text = profile.school
    }
    
    // MARK: - UI搭建
    private func setupUI() {
        // ScrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        // 头像
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.layer.cornerRadius = 40
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.image = UIImage(named: "avatar4")
        contentView.addSubview(avatarImageView)

        changeAvatarButton.setTitle("更换头像", for: .normal)
        changeAvatarButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(changeAvatarButton)
        changeAvatarButton.addTarget(self, action: #selector(changeAvatar), for: .touchUpInside)

        // 昵称
        nicknameField.placeholder = "\(profile.nickname) 编辑昵称"
        nicknameField.borderStyle = .roundedRect
        nicknameField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(nicknameField)

        // 性别
        genderControl.selectedSegmentIndex = 0
        genderControl.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(genderControl)

        // 生日
        birthdayPicker.datePickerMode = .date
        birthdayPicker.maximumDate = Date()
        birthdayPicker.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(birthdayPicker)
        birthdayPicker.addTarget(self, action: #selector(birthdayChanged), for: .valueChanged)

        // 标签
        tagField.placeholder = "\(profile.description) 编辑标签"
        tagField.borderStyle = .roundedRect
        tagField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(tagField)

        // 年龄
        ageLabel.text = "年龄：-"
        ageLabel.font = .systemFont(ofSize: 16)
        ageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ageLabel)

        // 地址
        addressField.placeholder = "地址"
        addressField.borderStyle = .roundedRect
        addressField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(addressField)

        // 学校
        schoolField.placeholder = "学校"
        schoolField.borderStyle = .roundedRect
        schoolField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(schoolField)

        // 保存按钮
        saveButton.setTitle("保存", for: .normal)
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.backgroundColor = UIColor.systemBlue
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.layer.cornerRadius = 8
        contentView.addSubview(saveButton)
        saveButton.addTarget(self, action: #selector(saveProfile), for: .touchUpInside)

        // 布局
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 80),
            avatarImageView.heightAnchor.constraint(equalToConstant: 80),

            changeAvatarButton.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 8),
            changeAvatarButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),

            nicknameField.topAnchor.constraint(equalTo: changeAvatarButton.bottomAnchor, constant: 32),
            nicknameField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32),
            nicknameField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32),
            nicknameField.heightAnchor.constraint(equalToConstant: 40),

            genderControl.topAnchor.constraint(equalTo: nicknameField.bottomAnchor, constant: 16),
            genderControl.leadingAnchor.constraint(equalTo: nicknameField.leadingAnchor),
            genderControl.trailingAnchor.constraint(equalTo: nicknameField.trailingAnchor),
            genderControl.heightAnchor.constraint(equalToConstant: 32),

            birthdayPicker.topAnchor.constraint(equalTo: genderControl.bottomAnchor, constant: 16),
            birthdayPicker.leadingAnchor.constraint(equalTo: nicknameField.leadingAnchor),
            birthdayPicker.trailingAnchor.constraint(equalTo: nicknameField.trailingAnchor),

            tagField.topAnchor.constraint(equalTo: birthdayPicker.bottomAnchor, constant: 16),
            tagField.leadingAnchor.constraint(equalTo: nicknameField.leadingAnchor),
            tagField.trailingAnchor.constraint(equalTo: nicknameField.trailingAnchor),
            tagField.heightAnchor.constraint(equalToConstant: 40),

            ageLabel.topAnchor.constraint(equalTo: tagField.bottomAnchor, constant: 16),
            ageLabel.leadingAnchor.constraint(equalTo: nicknameField.leadingAnchor),

            addressField.topAnchor.constraint(equalTo: ageLabel.bottomAnchor, constant: 16),
            addressField.leadingAnchor.constraint(equalTo: nicknameField.leadingAnchor),
            addressField.trailingAnchor.constraint(equalTo: nicknameField.trailingAnchor),
            addressField.heightAnchor.constraint(equalToConstant: 40),

            schoolField.topAnchor.constraint(equalTo: addressField.bottomAnchor, constant: 16),
            schoolField.leadingAnchor.constraint(equalTo: nicknameField.leadingAnchor),
            schoolField.trailingAnchor.constraint(equalTo: nicknameField.trailingAnchor),
            schoolField.heightAnchor.constraint(equalToConstant: 40),

            saveButton.topAnchor.constraint(equalTo: schoolField.bottomAnchor, constant: 32),
            saveButton.leadingAnchor.constraint(equalTo: nicknameField.leadingAnchor),
            saveButton.trailingAnchor.constraint(equalTo: nicknameField.trailingAnchor),
            saveButton.heightAnchor.constraint(equalToConstant: 44),
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40)
        ])
    }

    
    @objc private func changeAvatar() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }

    
    private func loadImage(from path: String) -> UIImage? {
        if path.isEmpty {
            return nil
        }
        return UIImage(contentsOfFile: path)
    }
    
    // MARK: - 生日选择，自动计算年龄
    @objc private func birthdayChanged() {
        profile.birthday = birthdayPicker.date
        ageLabel.text = "年龄：\(profile.age)"
    }

    // MARK: - 保存
    @objc private func saveProfile() {        // 收集数据
        profile.nickname = nicknameField.text ?? ""
        profile.gender = (genderControl.selectedSegmentIndex == 1) ? "女" : "男"
        profile.birthday = birthdayPicker.date
        profile.description = tagField.text ?? ""
        profile.address = addressField.text ?? ""
        profile.school = schoolField.text ?? ""

        profile.saveToUserDefaults()
        // 回调给上级页面
        delegate?.didUpdateProfile(profile)
        navigationController?.popViewController(animated: true)
    }
    
    private func saveImageToDocuments(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.9) else { return nil }
        let fileName = "avatar_\(Int(Date().timeIntervalSince1970)).jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        do {
            try data.write(to: url)
            return url.path
        } catch {
            print("保存头像失败: \(error)")
            return nil
        }
    }

}
