//
//  discoverListViewMode.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//

import SwiftUI

struct DiscoverItem: Identifiable {
    let id = UUID()
    let icon: String   // 图标名
    let title: String
    let subtitle: String? // 可选副标题
}

class discoverListViewModel : ObservableObject{
    
    @Published var discoverSections: [[DiscoverItem]] = [
        [
            DiscoverItem(icon: "circle.fill", title: "朋友圈", subtitle: nil)
        ],
        [
            DiscoverItem(icon: "qrcode", title: "扫一扫", subtitle: nil),
            DiscoverItem(icon: "waveform", title: "摇一摇", subtitle: nil)
        ],
        [
            DiscoverItem(icon: "location", title: "附近的人", subtitle: nil),
            DiscoverItem(icon: "gamecontroller", title: "游戏", subtitle: nil)
        ],
        [
            DiscoverItem(icon: "app", title: "小程序", subtitle: nil)
        ]
    ]
    
    
    
}
