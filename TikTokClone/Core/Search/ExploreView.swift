//
//  ExploreView.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import SwiftUI

struct ExploreView: View {
    
    var body: some View {
        NavigationStack {
            // UserListViewのNavigationLink(value: user)は、ユーザーが特定のユーザーを選択したときにそのuserオブジェクトをNavigationStackに渡します。
            // そして、.navigationDestination(for: User.self) {}は、そのuserオブジェクトを受け取り、ProfileViewに渡す
            UserListView(config: .search)
                .navigationTitle("Explore")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ExploreView()
}
