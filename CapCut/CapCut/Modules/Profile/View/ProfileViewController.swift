//
//  ProfileViewController.swift
//  CapCut
//
//  Created by WangBin on 2025/5/9.
//

import UIKit

class ProfileViewController: UIViewController , EditProfileDelegate {
    private let viewModel: ProfileViewModel
    
    
    
    init() {
        // 先用默认数据
        let Model = ProfileModel.loadFromUserDefaults() ?? ProfileModel()
        self.viewModel = ProfileViewModel(profile: Model)
        super.init(nibName: nil, bundle: nil)
    }

    let headerView = ProfileHeaderView()
    private let tableView = UITableView()

    // 功能菜单
    private let menuItems = [
        ("项目管理", "group_icon"),
        ("草稿箱", "favorite_icon"),
        ("模版管理", "inspiration_icon"),
        ("创作课堂", "classroom_icon"),
        ("帮助中心", "help_icon"),
        ("订单与发票", "order_icon")
    ]

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
    }

    private func setupUI() {
        view.backgroundColor = .white

        // 列表
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        view.addSubview(headerView)

        headerView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
          headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
          headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
          headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
          headerView.heightAnchor.constraint(equalToConstant: 80),
          tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
          tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
          tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
          tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
      ])
        
    //MARK: -调用viewmodel的数据
      headerView.configure(
        avatar: UIImage(named: viewModel.avatarURL),
        nickname: viewModel.nickname,
        desc: viewModel.description
      )
      headerView.onTap = { [weak self] in
          guard let self = self else { return }
          let editVC = EditProfileViewController(profile: self.viewModel.profile)
          editVC.delegate = self
          self.navigationController?.pushViewController(editVC, animated: true)
      }
        
    }

    // MARK: - 实现 EditProfileDelegate 协议方法
    func didUpdateProfile(_ profile: ProfileModel) {
        // 1. 更新 ViewModel
        viewModel.updateProfile(profile)
        // 2. 刷新 headerView 的UI
        headerView.configure(
            avatar: profile.avatarPath.isEmpty ? UIImage(named: "avatar4") : UIImage(contentsOfFile: profile.avatarPath),
            nickname: profile.nickname,
            desc: profile.description // 或 profile.description
        )
        
    }

}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        let (title, iconName) = menuItems[indexPath.row]
        cell.textLabel?.text = title
        cell.imageView?.image = UIImage(named: iconName)
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //MARK: - 处理菜单点击
        
        let (title , _ ) = menuItems[indexPath.row]
        switch title{
        case "项目管理" :
            let viewModel = ProjectViewModel(itemStatus: .project)
            let projectListVC = ProjectListViewController(viewmodel: viewModel)
            navigationController?.pushViewController(projectListVC, animated: true)
        case "草稿箱" :
            let viewModel = ProjectViewModel(itemStatus: .draft)
            let draftListVC = ProjectListViewController(viewmodel: viewModel)
            navigationController?.pushViewController(draftListVC, animated: true)
        default :
            print("\(title)")
        }
    }
}

