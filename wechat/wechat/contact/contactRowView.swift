//
//  contactRowView.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//

import SwiftUI

struct contactRowView: View {
    let contact : contact
    var body: some View {
        HStack(spacing : 12){
            Image(contact.avatar)
                .resizable()
                .frame(width: 48 , height: 48)
                .cornerRadius(5)
            Text("\(contact.name)")
                .font(.system(size: 22))
                .padding(.leading , 12)
            Spacer()
        }.padding(.vertical , 6)
    }
}

#Preview {
    let contact : contact = contact(id: "1" , avatar: "img1" , name: "王彬")
    contactRowView(contact: contact)
}
