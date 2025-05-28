//
//  ContentView.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
            TabView {
                MainMessageView()
                    .tabItem {
                        Image(systemName: "message.fill")
                        Text("微信")
                    }
                MainContactView()
                    .tabItem {
                        Image(systemName: "person.2.fill")
                        Text("通讯录")
                    }
                MainDiscoverView()
                    .tabItem {
                        Image(systemName: "safari.fill")
                        Text("发现")
                    }
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("我")
                    }
            }
        }
}

#Preview {
    ContentView()
}
