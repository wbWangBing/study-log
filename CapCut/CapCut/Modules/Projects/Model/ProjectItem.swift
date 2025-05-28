//
//  ProjectItem.swift
//  CapCut
//
//  Created by ByteDance on 2025/5/13.
//

import Foundation

enum ItemStatus : String , Codable {
    case  draft = "draft" //草稿
    case  project = "project" //正式项目
}

struct ProjectItem : Codable , Identifiable{
    var id : String = UUID().uuidString // 标识符
    var title : String //项目标题
    var coverImagePath : String? //项目封面图片地址
    var creationDate : Date //创建时间
    var lastModifiedDate : Date //最近修改时间
    var status : ItemStatus //标识符 草稿 or 正式项目
    var projectFilePath : String? // 项目文件地址
    var duration : TimeInterval? //视频时长
    
    // 构造函数
    init(id: String = UUID().uuidString,
         title: String,
         status: ItemStatus,
         creationDate: Date = Date(),
         lastModifiedDate: Date = Date(),
         coverImagePath: String? = nil,
         projectFilePath: String? = nil,
         duration: TimeInterval? = nil) {
        self.id = id
        self.title = title
        self.status = status
        self.creationDate = creationDate
        self.lastModifiedDate = lastModifiedDate
        self.coverImagePath = coverImagePath
        self.projectFilePath = projectFilePath
        self.duration = duration
    }
}
