//
//  MainTabBarController.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/9.
//

import UIKit

class MainTabBarController : UITabBarController{
    override func viewDidLoad() {
        super.viewDidLoad()
        let clipVC = ClipViewController()
        clipVC.tabBarItem = UITabBarItem(title: "剪辑", image: UIImage(named: "clip_icon"), tag: 0)
        
        let templateVC = TemplateViewController()
        templateVC.tabBarItem = UITabBarItem(title: "剪同款", image: UIImage(named: "template_icon"), tag: 1)
        
        let messageVC = MessageViewController()
        messageVC.tabBarItem = UITabBarItem(title: "消息", image: UIImage(named: "message_icon"), tag: 2)
        
        let profileVC = ProfileViewController()
        profileVC.tabBarItem = UITabBarItem(title: "个人", image: UIImage(named: "profile_icon"), tag: 3)
        
        viewControllers = [
            UINavigationController(rootViewController: clipVC),
            UINavigationController(rootViewController: templateVC),
            UINavigationController(rootViewController: messageVC),
            UINavigationController(rootViewController: profileVC)
        ]
    }
    
}
