//
//  ProfileViewModel.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//

import SwiftUI

struct ProfileInfo {
    let avatar: String
    let name: String
    let wechatID: String
}

struct ProfileItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String?
}

class ProfileViewModel : ObservableObject{
    @Published var profileInfo = ProfileInfo(avatar: "img1", name: "王彬", wechatID: "wxid_123456")
    @Published var profileSections : [[ProfileItem]] = [
        [
            ProfileItem(icon: "creditcard", title: "支付", subtitle: nil)
        ],
        [
            ProfileItem(icon: "star", title: "收藏", subtitle: nil),
            ProfileItem(icon: "photo.on.rectangle", title: "朋友圈", subtitle: nil),
            ProfileItem(icon: "creditcard", title: "卡包", subtitle: nil),
            ProfileItem(icon: "face.smiling", title: "表情", subtitle: nil)
        ],
        [
            ProfileItem(icon: "gearshape", title: "设置", subtitle: nil)
        ]
    ]
    
}
