//
//  ProfileView.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//

import SwiftUI

struct ProfileView: View {
    @StateObject var viewModel = ProfileViewModel()
    var body: some View {
        List {
            // 个人信息卡片
            Section {
                ProfileHeaderView(info: viewModel.profileInfo )
                    .listRowInsets(EdgeInsets())
            }
            .textCase(nil)
            .frame(height: 110)
            // 分组功能
            ForEach(0..<viewModel.profileSections.count, id: \.self) { sectionIndex in
                Section {
                    ForEach(viewModel.profileSections[sectionIndex]) { item in
                        ProfileRowView(item: item)
                    }
                }
                .textCase(nil)
                .listSectionSpacing(8)
            }
        }
        .listStyle(.grouped)
        .background(Color(.systemGray6))
    }
}

#Preview {
    ProfileView()
}
