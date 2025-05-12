//
//  ClipViewController.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/9.
//

import UIKit

class ClipViewController: UIViewController {
    private let viewModel = ClipViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "剪辑"
        
        // 这里可以添加UI元素，并通过viewModel管理数据
    }
}

