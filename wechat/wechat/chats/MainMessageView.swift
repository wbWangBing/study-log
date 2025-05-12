//
//  MainMessageView.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//

import SwiftUI

struct MainMessageView: View {
    
    var body : some View {
        NavigationView{
            chatListView()
                .navigationBarTitle("微信", displayMode: .inline )
                .toolbar{
                    ToolbarItem(placement : .navigationBarTrailing){
                        HStack(spacing : 8){
                            Button(action: {}){
                                Image(systemName: "plus.circle")
                                    .font(.system(size : 20))
                                    .colorMultiply(Color.secondary)
                            }
                            Button(action: {} ){
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size : 20))
                                    .colorMultiply(Color.gray)
                            }
                        }
                    }
                }
        }
    }
}

#Preview {
    MainMessageView()
}
