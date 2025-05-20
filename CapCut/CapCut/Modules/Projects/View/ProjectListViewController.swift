//
//  ProjectListViewController.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/13.
//

import UIKit
import Combine
import PhotosUI // 导入 PhotosUI 以便后续可能使用 PHPickerViewController

class ProjectListViewController: UIViewController {

    private var collectionView: UICollectionView! // 修改为 UICollectionView
    
    private let viewModel : ProjectViewModel
    
    private var cancellables = Set<AnyCancellable>()
    
    // 用于临时存储待创建项目的信息
    private var pendingProjectTitle: String?
    private var pendingProjectStatus: ItemStatus?
    
    // 用于临时存储待编辑项目的信息
    private var editingProject: ProjectItem?
    private var isChangingCoverForEditingProject: Bool = false
    
    // 定义单元格的边距和间距
    private let sectionInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    private let itemsPerRow: CGFloat = 3
    private let interitemSpacing: CGFloat = 3.0 // 项目之间的水平间距
    private let lineSpacing: CGFloat = 3.0      // 行之间的垂直间距
    
    init(viewmodel : ProjectViewModel){
        self.viewModel = viewmodel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "项目管理"
        view.backgroundColor = .white
        setupCollectionView() // 修改方法名
        setupBindings()
        setupNavigationBar()
    }

    private func setupCollectionView() { // 修改方法实现
        let layout = UICollectionViewFlowLayout()
        // itemSize 将在 delegate 中动态计算
        layout.minimumInteritemSpacing = interitemSpacing
        layout.minimumLineSpacing = lineSpacing
        layout.sectionInset = sectionInsets

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProjectCollectionViewCell.self, forCellWithReuseIdentifier: ProjectCollectionViewCell.identifier)
    }

    private func setupBindings() {
        viewModel.$projectItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData() // 修改为 collectionView
            }
            .store(in: &cancellables)


        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                if let msg = message, !msg.isEmpty {
                   
                    print("错误: \(msg)")
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
    }

    @objc private func didTapAddButton() {
        let alertController = UIAlertController(title: "新建项目", message: "请输入项目标题", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "项目标题"
        }
        
        let createProjectAction = UIAlertAction(title: "创建项目", style: .default) { [weak self, weak alertController] _ in
            guard let title = alertController?.textFields?.first?.text, !title.isEmpty else { return }
            self?.pendingProjectTitle = title
            self?.pendingProjectStatus = .project
            self?.presentImagePicker()
        }
        
        let createDraftAction = UIAlertAction(title: "创建草稿", style: .default) { [weak self, weak alertController] _ in
            guard let title = alertController?.textFields?.first?.text, !title.isEmpty else { return }
            self?.pendingProjectTitle = title
            self?.pendingProjectStatus = .draft
            self?.presentImagePicker()
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alertController.addAction(createProjectAction)
        alertController.addAction(createDraftAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }

    private func presentImagePicker() {
        // 检查照片库权限 (实际应用中应该更早检查，并处理拒绝的情况)
        // 这里为了简化，直接尝试弹出
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            // imagePicker.allowsEditing = true // 如果允许用户编辑选择的图片
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("照片库不可用")
            // 如果照片库不可用，可以选择不带封面创建或提示用户
            if let title = pendingProjectTitle, let status = pendingProjectStatus {
                viewModel.createProject(title: title, status: status, coverImagePath: nil)
                clearPendingProjectInfo()
            }
        }
    }

    private func saveImageToDocumentsDirectory(image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { // 或者使用 pngData()
            print("无法将图片转换为JPEG数据")
            return nil
        }
        
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileName = UUID().uuidString + ".jpg" // 创建唯一文件名
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                print("图片已保存到: \(fileURL.path)")
                return fileName // 
            } catch {
                print("保存图片失败: \(error)")
                return nil
            }
        }
        return nil
    }
    
    private func clearPendingProjectInfo() {
        pendingProjectTitle = nil
        pendingProjectStatus = nil
    }
    private func clearEditingProjectInfo() {
        editingProject = nil
        isChangingCoverForEditingProject = false
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension ProjectListViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        var selectedImage: UIImage?
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        guard let imageToSave = selectedImage else {
            print("未选择图片或获取图片失败。")
            clearPendingProjectInfo() // 清理创建项目的临时信息
            clearEditingProjectInfo() // 清理编辑项目的临时信息
            return
        }
        
        // 场景 1: 为现有项目更换封面
        if isChangingCoverForEditingProject, var projectToUpdate = editingProject {
            // 1. (可选) 删除旧封面
            if let oldCoverName = projectToUpdate.coverImagePath, !oldCoverName.isEmpty {
                deleteCoverImageFile(named: oldCoverName)
            }
            
            // 2. 保存新封面
            if let newCoverImageName = saveImageToDocumentsDirectory(image: imageToSave) {
                projectToUpdate.coverImagePath = newCoverImageName
                viewModel.updateProject(projectToUpdate)
            } else {
                // 保存新封面失败，可以提示用户
                print("更换封面失败：无法保存新图片。")
                // 注意: 如果 viewModel.updateProject 失败或不被调用，项目可能保留旧封面或无封面
            }
            clearEditingProjectInfo()

        // 场景 2: 创建带封面的新项目
        } else if let title = pendingProjectTitle, let status = pendingProjectStatus {
            // 这个 else if 暗示 !isChangingCoverForEditingProject (或者 editingProject 是 nil)
            // 并且我们有待创建新项目的标题和状态。
            if let imagePath = saveImageToDocumentsDirectory(image: imageToSave) {
                viewModel.createProject(title: title, status: status, coverImagePath: imagePath)
            } else {
                // 保存图片失败，不带封面创建
                print("为新项目保存封面图片失败，将不带封面创建。")
                viewModel.createProject(title: title, status: status, coverImagePath: nil)
            }
            clearPendingProjectInfo()
            
        // 场景 3: 回退或错误情况 (理论上不应到达)
        } else {
            print("图片选择完成，但项目状态不明确（既非编辑也无待创建信息）。")
            // 以防万一，清除所有临时状态。
            clearPendingProjectInfo()
            clearEditingProjectInfo()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        print("图片选择已取消")
        
        // 如果是在创建新项目过程中取消了图片选择，
        // 仍然按照原逻辑创建不带封面的项目。
        if !isChangingCoverForEditingProject, let title = pendingProjectTitle, let status = pendingProjectStatus {
             viewModel.createProject(title: title, status: status, coverImagePath: nil)
        }
        // 无论如何，取消时都清除临时状态。
        clearPendingProjectInfo()
        clearEditingProjectInfo()
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension ProjectListViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout { // 修改协议
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.projectItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProjectCollectionViewCell.identifier, for: indexPath) as? ProjectCollectionViewCell else {
            fatalError("Unable to dequeue ProjectCollectionViewCell")
        }
        let project = viewModel.projectItems[indexPath.row]
        cell.configure(with: project)
        return cell
    }
    
    //MARK: -点击后播放项目，异步加载，先播放封面加载完毕再播放视频
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let project = viewModel.projectItems[indexPath.row]
        // TODO: 处理项目点击事件，例如打开编辑器
        print("点击了项目: \(project.title)")
    }

    // MARK: - Context Menu 编辑与删除
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPath.row < viewModel.projectItems.count else { return nil }
        
        let projectItem = viewModel.projectItems[indexPath.row]
        
        let configuration = UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
            
            let editTitleAction = UIAction(title: "编辑标题", image: UIImage(systemName: "pencil")) { _ in
                self?.presentEditTitleAlert(for: projectItem)
            }
            
            let changeCoverAction = UIAction(title: "更换封面", image: UIImage(systemName: "photo")) { _ in
                self?.editingProject = projectItem
                self?.isChangingCoverForEditingProject = true
                self?.presentImagePicker() // 复用现有的图片选择器
            }
            
            let deleteAction = UIAction(title: "删除", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                self?.confirmAndDeleteProject(projectItem, at: indexPath)
            }
            
            return UIMenu(title: "", children: [editTitleAction, changeCoverAction, deleteAction])
        }
        return configuration
    }

    private func presentEditTitleAlert(for project: ProjectItem) {
        let alertController = UIAlertController(title: "编辑项目标题", message: "请输入新的项目标题", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "项目标题"
            textField.text = project.title // 预填当前标题
        }
        
        let saveAction = UIAlertAction(title: "保存", style: .default) { [weak self, weak alertController] _ in
            guard let newTitle = alertController?.textFields?.first?.text, !newTitle.isEmpty else { return }
            
            var updatedProject = project
            updatedProject.title = newTitle
            // 如果有其他需要编辑的属性，也在这里更新
            
            self?.viewModel.updateProject(updatedProject)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func confirmAndDeleteProject(_ project: ProjectItem, at indexPath: IndexPath) {
        let alertController = UIAlertController(
            title: "确认删除",
            message: "您确定要删除项目 \"\(project.title)\" 吗？此操作不可撤销。",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "删除", style: .destructive) { [weak self] _ in
            self?.deleteProjectFilesAndData(project)
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    

    
    private func deleteProjectFilesAndData(_ project: ProjectItem) {
        // 1. 删除关联的封面图片（如果存在）
        if let coverImageName = project.coverImagePath, !coverImageName.isEmpty {
            deleteCoverImageFile(named: coverImageName) // 使用新的辅助方法
        }
        
        if let projectFilePath = project.projectFilePath, !projectFilePath.isEmpty{
            deleteProjectFile(path: projectFilePath)
        }
        // 2. 从 ViewModel 删除项目数据 (这将触发UI更新)
        viewModel.deleteProject(item: project)
    }
    
    private func deleteCoverImageFile(named imageName: String) {
        let fileManager = FileManager.default
        if let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
            let imageFileURL = documentsDirectory.appendingPathComponent(imageName)
            if fileManager.fileExists(atPath: imageFileURL.path) {
                do {
                    try fileManager.removeItem(at: imageFileURL)
                    print("已删除旧封面图片: \(imageFileURL.path)")
                } catch {
                    print("删除旧封面图片失败: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func deleteProjectFile(path projectFilePath: String) {
        let fileManager = FileManager.default
        // projectFilePath IS ALREADY AN ABSOLUTE PATH.
        // We should create the URL directly from it.
        let fileURL = URL(fileURLWithPath: projectFilePath) // 直接使用绝对路径创建 URL
        print("将要删除的 video at: \(fileURL.path)") // 打印将要检查的正确路径

        if fileManager.fileExists(atPath: fileURL.path) { // 使用修正后的 fileURL.path
            do {
                try fileManager.removeItem(at: fileURL)
                print("已删除视频: \(fileURL.path)")
            } catch {
                print("删除视频失败: \(error.localizedDescription)")
            }
        } else {
            print("视频文件未找到 (fileExists failed for): \(fileURL.path)") // 更清晰的错误日志
        }
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = sectionInsets.left + sectionInsets.right + (interitemSpacing * (itemsPerRow - 1))
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        // 模仿抖音作品，通常是竖向的视频封面，比如 4:5 或 3:4 的宽高比
        // 这里用一个常见的 4:3 宽高比
        let heightPerItem = widthPerItem * (4.0 / 3.0)
        return CGSize(width: widthPerItem, height: heightPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interitemSpacing
    }
}
