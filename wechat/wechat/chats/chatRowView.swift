//
//  chatRowView.swift
//  WeChat
//
//  Created by WangbIn on 2025/5/8.
//

import SwiftUI

struct chatRowView : View{
    
    let chat : Chat
    var body : some View{
        
            HStack{
                Image(chat.avatar)
                    .resizable()
                    .frame(width: 48 , height : 48)
                    .cornerRadius(5)
                    .padding(.leading , 4)
                VStack{
                    HStack{
                        VStack(alignment : .leading) {
                            Text(chat.name)
                                .font(.headline)
                            Text(chat.lastMessage)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }.padding(.horizontal , 8)
                        Spacer()
                        
                        VStack{
                            Text(chat.time)
                                .font(.caption)
                                .foregroundColor(.gray)
                            if(chat.unreadCount>0){
                                Text("\(chat.unreadCount)")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                                    .padding(4)
                                    .background(Circle().fill(Color.red))
                            }
                        }.padding(.horizontal , 18)
                    }

                }
            }
            .background(Color.clear)
            .padding(.vertical,0)
           
        
    }
}

#Preview {
    let chat : Chat =   Chat(id: "1", avatar: "img1", name: "张三", lastMessage: "你好，最近怎么样？", time: "09:30", unreadCount: 2)
    chatRowView(chat : chat)
}
