//
//  ProfileRowView.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//

import SwiftUI

struct ProfileRowView: View {
    let item: ProfileItem
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: item.icon)
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(.green)
                .padding(.leading , 18)
            Text(item.title)
                .font(.system(size: 17))
            Spacer()
            if let subtitle = item.subtitle {
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .padding(28)
        }
        .padding(.vertical, 8)
        .frame(height: 40)
    }
}


#Preview {
    let item : ProfileItem = ProfileItem(icon: "creditcard", title: "支付", subtitle: nil)
    ProfileRowView(item: item)
}
