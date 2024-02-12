//
//  ProfileView.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject var profileViewModel: ProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    private var user: User {
        return profileViewModel.user
    }
    
    init(user: User) {
        let viewModel = ProfileViewModel(user: user,
                                                userService: UserService(),
                                                postService: PostService())
        self._profileViewModel = StateObject(wrappedValue: viewModel)
        
        UINavigationBar.appearance().tintColor = .primaryText
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 2) {
                
                ProfileHeaderView(viewModel: profileViewModel)
                
                PostGridView(viewModel: profileViewModel)
            }
        }
        .navigationDestination(for: UserListConfig.self, destination: { config in
            UserListView(config: config)
        })
        .task {
            await profileViewModel.fetchUserPosts()
            await profileViewModel.checkIfUserIsFollowed()
            await profileViewModel.fetchUserStats()
            print("DEBUG: profile task \(user.stats)")
        }
        .navigationTitle("Profile")
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.primaryText)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    ProfileView(user: DeveloperPreview.user)
}
