//
//  DiscoverListView.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//

import SwiftUI

struct DiscoverListView: View {
    @StateObject var viewModel = discoverListViewModel()
   
    var body: some View {
        List{
            ForEach(0..<viewModel.discoverSections.count , id :\.self){sectionIndex in
                Section{
                    ForEach(viewModel.discoverSections[sectionIndex]){item in
                        DiscoverRowView(item: item)
                    }
                }
                .listRowSeparator(.visible)
                .listRowInsets(EdgeInsets())
    
               
            }
        }
        .listSectionSpacing(12)

    }
}

#Preview {
    DiscoverListView()
}
