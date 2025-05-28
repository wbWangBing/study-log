//
//  TemplateViewModel.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/9.
//

import Foundation
import UIKit

struct TemplateModel {
    let coverImageName: String
    let title: String
    let avatarImageName: String
    let nickname: String
    let hotText: String
    let imageWidth: CGFloat
    let imageHeight: CGFloat

    init(coverImageName: String, title: String, avatarImageName: String, nickname: String, hotText: String) {
        self.coverImageName = coverImageName
        self.title = title
        self.avatarImageName = avatarImageName
        self.nickname = nickname
        self.hotText = hotText
        if let image = UIImage(named: coverImageName) {
            self.imageWidth = image.size.width
            self.imageHeight = image.size.height
        } else {
            self.imageWidth = 1
            self.imageHeight = 1
        }
    }
}


class TemplateViewModel {
    var templates: [TemplateModel] = []
    func loadTemplates(completion: @escaping () -> Void) {
        // 这里模拟加载数据，后续用model提供的接口获得数据
    templates = [
        TemplateModel(
            coverImageName: "cover1",
            title: "悦郁的闺蜜",
            avatarImageName: "avatar1",
            nickname: "方方不方",
            hotText: "2.8万"
        ),
        TemplateModel(
            coverImageName: "cover2",
            title: "花开的时候你就来看我",
            avatarImageName: "avatar2",
            nickname: "平安",
            hotText: "2.5万"
        ),
        TemplateModel(
            coverImageName: "cover3",
            title: "夏日的微风",
            avatarImageName: "avatar3",
            nickname: "微风使者",
            hotText: "3.1万"
        ),
        TemplateModel(
            coverImageName: "cover4",
            title: "冬日的雪景",
            avatarImageName: "avatar4",
            nickname: "雪之精灵",
            hotText: "2.9万"
        ),
        TemplateModel(
            coverImageName: "cover5",
            title: "森林的秘密",
            avatarImageName: "avatar5",
            nickname: "森林守护者",
            hotText: "3.3万"
        )
    ]
        completion()
    }
}
