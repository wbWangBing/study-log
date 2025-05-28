//
//  ClipViewController.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/9.
//

import UIKit
import AVFoundation
import MobileCoreServices // For kUTTypeMovie
import Combine // For observing ViewModel changes
import CoreData

class ClipViewController: UIViewController {
    
    private let viewModel: ClipViewModel
    private var cancellables = Set<AnyCancellable>()
    private let managedObjectContext: NSManagedObjectContext // 添加 managedObjectContext 属性

    // MARK: - AVPlayer Properties
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var isPlaying: Bool = false
    private var currentProjectItem: ProjectItem? // 用于存储当前编辑的项目


   
    // MARK: - UI Components
    private lazy var playerComponent: PlayerComponent = {
        // 在初始化时传入 viewModel
        let component = PlayerComponent(viewModel: self.viewModel)
        component.translatesAutoresizingMaskIntoConstraints = false
        return component
    }()

    private lazy var timelineComponent: TimelineComponent = {
        // 在初始化时传入 viewModel
        let component = TimelineComponent(viewModel: self.viewModel)
        component.translatesAutoresizingMaskIntoConstraints = false
        return component
    }()

    private lazy var toolbarComponent: ToolbarComponent = {
        // 在初始化时传入 viewModel
        let component = ToolbarComponent(viewModel: self.viewModel)
        component.translatesAutoresizingMaskIntoConstraints = false
        // 设置按钮点击的回调：当 ToolbarComponent 中的按钮被点击时，执行这里的代码
        component.onAddMediaButtonTapped = { [weak self] in
            // 调用 ClipViewController 中的 presentVideoPicker 方法
            self?.presentVideoPicker() 
        }
        return component
    }()
    
    // MARK: - Initialization
    // 修改 init 方法以接收 managedObjectContext
    init(projectItem: ProjectItem? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not get AppDelegate")
        }
        
        let context = appDelegate.persistentContainer.viewContext

        self.managedObjectContext = context // 保存 managedObjectContext
        // 在初始化 ClipViewModel 时传入 managedObjectContext
        self.viewModel = ClipViewModel(projectItem: projectItem, managedObjectContext: managedObjectContext)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "剪辑"
        
        setupUI()
        setupBindings()
        
        // Initial UI update is now partially handled by components themselves
        // We still need to pass the playerLayer from viewModel to playerComponent
        // and manage overall visibility based on viewModel state.
        updateUIForVideoState(viewModel.videoState, playerLayer: viewModel.playerLayer)
        
        // The configure calls are no longer needed here
        playerComponent.addStartCreatingGesture(self, action: #selector(didTapStartCreating))
        timelineComponent.addPlayPauseButtonTarget(self, action: #selector(didTapPlayPauseButton))
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // PlayerComponent's internal layoutSubviews will handle its playerLayer frame
    }

    private func setupUI() {
        view.addSubview(playerComponent)
        view.addSubview(timelineComponent)
        view.addSubview(toolbarComponent)

        NSLayoutConstraint.activate([
            playerComponent.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            playerComponent.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerComponent.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerComponent.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),

            toolbarComponent.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            toolbarComponent.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarComponent.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarComponent.heightAnchor.constraint(equalToConstant: 100),

            timelineComponent.topAnchor.constraint(equalTo: playerComponent.bottomAnchor),
            timelineComponent.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timelineComponent.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timelineComponent.bottomAnchor.constraint(equalTo: toolbarComponent.topAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.$videoState
            .combineLatest(viewModel.$playerLayer, viewModel.$isPlaying)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] videoState, playerLayer, isPlaying in
                guard let self = self else { return }
                self.updateUIForVideoState(videoState, playerLayer: playerLayer)
                self.timelineComponent.updatePlayPauseButton(isPlaying: isPlaying, isEnabled: videoState == .videoLoaded)
            }
            .store(in: &cancellables)
    }

    private func updateUIForVideoState(_ state: VideoLoadState, playerLayer: AVPlayerLayer?) {
        playerComponent.playerLayer = playerLayer // Pass the layer to the component
        
        // Components might already set their initial visibility based on viewModel
        // But overall layout/visibility control can still be here
        switch state {
        case .noVideo:
            playerComponent.showStartCreatingView(true) // Ensure this is called
            playerComponent.playerLayer?.isHidden = true
            timelineComponent.isHidden = true
            toolbarComponent.isHidden = true
        case .videoLoaded:
            playerComponent.showStartCreatingView(false) // Ensure this is called
            playerComponent.playerLayer?.isHidden = false
            timelineComponent.isHidden = false
            toolbarComponent.isHidden = false
        }
    }
    
    @objc private func didTapStartCreating() {
        let alertController = UIAlertController(title: "创建新剪辑", message: nil, preferredStyle: .actionSheet)

        let importFromPhotosAction = UIAlertAction(title: "从相册导入新视频", style: .default) { [weak self] _ in
            self?.presentVideoPicker() // "开始创作"按钮也调用这个方法
        }
        alertController.addAction(importFromPhotosAction)

        let importFromProjectsAction = UIAlertAction(title: "从现有项目导入", style: .default) { [weak self] _ in
            print("从现有项目导入 - 功能待实现")
            let comingSoonAlert = UIAlertController(title: "敬请期待", message: "从现有项目导入的功能正在开发中。", preferredStyle: .alert)
            comingSoonAlert.addAction(UIAlertAction(title: "好的", style: .default))
            self?.present(comingSoonAlert, animated: true)
        }
        alertController.addAction(importFromProjectsAction)

        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)

        if let popoverController = alertController.popoverPresentationController {
            popoverController.sourceView = self.playerComponent // Source view is now playerComponent
            popoverController.sourceRect = self.playerComponent.bounds // Or a specific subview within playerComponent
            popoverController.permittedArrowDirections = []
        }
        present(alertController, animated: true, completion: nil)
    }

    private func presentVideoPicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String] // 确保 MobileCoreServices 已导入
        present(picker, animated: true, completion: nil)
    }

    // MARK: - Playback Controls
    @objc private func didTapPlayPauseButton() {
        viewModel.togglePlayPause()
    }
    
    deinit {
        // NotificationCenter observers are handled by ViewModel now
        // Cancellables will be automatically deallocated
        print("ClipViewController deinit")
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ClipViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let videoURL = info[.mediaURL] as? URL else {
            print("无法获取视频 URL")
            // TODO: Show error to user
            return
        }
        // 更新方法调用
        viewModel.handleVideoImport(from: videoURL)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

