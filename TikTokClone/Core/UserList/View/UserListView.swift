//
//  UserListView.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import SwiftUI

struct UserListView: View {
    
    @State var searchText = ""
    @StateObject var viewModel = UserListViewModel(service: UserListService())
    
    private let config: UserListConfig
    
    init(config: UserListConfig) {
        self.config = config
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.users) { user in
                    NavigationLink(value: user) {
                        UserCell(user: user)
                            .padding(.horizontal)
                    }
                }
                
            }
            .searchable(text: $searchText, prompt: "Search..")
            .onChange(of: searchText) { _, newValue in
                if newValue.isEmpty {
                    Task { await viewModel.fetchUsers(forConfig: config) }
                } else {
                    viewModel.filterUsers(with: newValue)
                }
            }
            .navigationDestination(for: User.self) { user in
                ProfileView(user: user)
            }
            .navigationTitle(config.navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .padding(.top)
        }
        .task { await viewModel.fetchUsers(forConfig: config) }
    }
}

#Preview {
    UserListView(config: .search)
}
