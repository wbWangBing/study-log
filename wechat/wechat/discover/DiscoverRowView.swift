//
//  DiscoverRowView.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//

import SwiftUI

struct DiscoverRowView: View {
    let item : DiscoverItem
    var body : some View{
        HStack(spacing : 16){
            Image(systemName: item.icon)
                .resizable()
                .frame(width: 28 , height: 28)
                .foregroundColor(.green)
            Text(item.title)
                .font(.system(size: 13))
                .foregroundColor(.gray)
            Spacer()
            if let subtitle = item.subtitle{
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .padding(.vertical , 8)
        }.padding(.vertical , 8)
        .padding(.horizontal , 18)
        .frame(width:.infinity, height: 40 )
        
    }
}

#Preview {
    var item : DiscoverItem =  DiscoverItem(icon: "circle.fill", title: "朋友圈", subtitle: nil)
    DiscoverRowView(item : item)
}
