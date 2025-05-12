//
//  chatListView.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//

import SwiftUI

struct chatListView: View {
    @StateObject var viewModel = chatViewListViewModel()
    
    var body: some View {
        List(viewModel.chats){ chat in
            chatRowView(chat : chat)
        }
        .listStyle(.plain)
        .listRowSeparator(.hidden) // 隐藏系统分割线
    }
    
}

#Preview {
    chatListView()
}
