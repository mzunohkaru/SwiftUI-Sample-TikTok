//
//  UserListViewModel.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import Foundation

@MainActor
class UserListViewModel: ObservableObject {
    
    @Published var users = [User]()
    private let service: UserListService
    
    init(service: UserListService) {
        self.service = service
    }
    
    func fetchUsers(forConfig config: UserListConfig) async {
        do {
            self.users = try await service.fetchUsers(forConfig: config)
        } catch {
            print("DEBUG: Failed to fetch users with error \(error.localizedDescription)")
        }
    }
    
    // User 検索
    func filterUsers(with query: String) {
        let lowercaseQuery = query.lowercased()
        self.users = users.filter{
            $0.username.lowercased().contains(lowercaseQuery) ||
            $0.fullname.lowercased().contains(lowercaseQuery)
        }
    }
}
