//
//  MessageViewController.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/9.
//

import UIKit

class MessageViewController: UIViewController {
    private let viewModel = MessageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "消息"
        
        // 这里可以添加UI元素，并通过viewModel管理数据
    }
}
