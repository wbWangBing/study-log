//
//  contactListView.swift
//  WeChat
//
//  Created by ByteDance on 2025/5/8.
//

import SwiftUI

struct contactListView: View {
    @StateObject var viewModel = contactListViewModel()
    var body: some View {
        List(viewModel.contacts){contact in
            contactRowView(contact: contact)
        }
        .listStyle(.plain)
    }
}

#Preview {
    contactListView()
}
