//
//  ProfileHeaderView.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//

import SwiftUI

struct ProfileHeaderView: View {
    let info: ProfileInfo
    var body: some View {
        HStack {
            Image(info.avatar)
                .resizable()
                .frame(width: 65, height: 65)
                .cornerRadius(10)
                .padding(.trailing, 8)
            VStack(alignment: .leading, spacing: 6) {
                Text(info.name)
                    .font(.system(size: 20, weight: .medium))
                Text("微信号: \(info.wechatID)")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Spacer()
            Image(systemName: "qrcode")
                .font(.system(size: 24))
                .foregroundColor(.gray)
                .padding(.trailing, 2)
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 16)
        .background(Color.white)

    }
}


#Preview {
    let profileinfo : ProfileInfo = ProfileInfo(avatar: "img1", name: "王彬", wechatID: "wxid_123456")
    ProfileHeaderView(info : profileinfo)
}
