//
//  contactListViewModel.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//
import SwiftUI

struct contact : Identifiable{
    let id : String
    let avatar : String
    let name : String
}

class contactListViewModel : ObservableObject{
    
    @Published var contacts : [contact] = [
        contact(id: "1", avatar: "img1", name: "张三"),
        contact(id: "2", avatar: "img1", name: "李四"),
    ]
}
