//
//  chatListViewModel.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//
import SwiftUI

//定义消息列表结构体
struct Chat : Identifiable{
    let id : String
    let avatar : String
    let name : String
    let lastMessage : String
    let time : String
    let unreadCount : Int
}

class chatViewListViewModel : ObservableObject{
    @Published var chats: [Chat] = [
        Chat(id: "1", avatar: "img1", name: "张三", lastMessage: "你好，最近怎么样？", time: "09:30", unreadCount: 2),
        Chat(id: "2", avatar: "img1", name: "李四", lastMessage: "明天一起吃饭吗？", time: "昨天", unreadCount: 0),
        Chat(id: "3", avatar: "img1", name: "王五", lastMessage: "[图片]", time: "周一", unreadCount: 1),
        Chat(id: "4", avatar: "img1", name: "小明", lastMessage: "收到，谢谢！", time: "08:15", unreadCount: 0),
        Chat(id: "5", avatar: "img1", name: "同事群", lastMessage: "会议10点开始", time: "07:45", unreadCount: 3)
    ]
}
