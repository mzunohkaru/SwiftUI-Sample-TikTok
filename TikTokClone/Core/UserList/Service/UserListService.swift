//
//  UserListService.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import Firebase
import FirebaseFirestore

class UserListService {
    
    func fetchUsers() async throws -> [User] {
        let users = try await FirestoreConstants.UserCollection.getDocuments(as: User.self)
        // 現在のユーザーの uid 取得
        guard let uid = Auth.auth().currentUser?.uid else { return users }
        // users配列から、現在のユーザーの uid と一致する要素をフィルターにかける
        return users.filter({ $0.id != uid })
    }
    
    func fetchUsers(forConfig config: UserListConfig) async throws -> [User] {
        switch config {
        case .blocked:
            return []
        case .followers(let uid):
            return try await fetchFollowers(uid: uid)
        case .following(let uid):
            return try await fetchFollowing(uid: uid)
        case .likes(_):
            return []
        case .search:
            return try await fetchUsers()
        case .newMessage:
            return []
        }
    }
    
    private func fetchFollowers(uid: String) async throws -> [User] {
        let snapshot = try await FirestoreConstants
            .FollowersCollection
            .document(uid)
            .collection("user-followers")
            .getDocuments()
        
        return try await fetchUsers(snapshot)
    }
    
    private func fetchFollowing(uid: String) async throws -> [User] {
        let snapshot = try await FirestoreConstants
            .FollowingCollection
            .document(uid)
            .collection("user-following")
            .getDocuments()
        
        return try await fetchUsers(snapshot)
    }
    
    private func fetchUsers(_ snapshot: QuerySnapshot) async throws -> [User] {
        var users = [User]()
        
        for doc in snapshot.documents {
            let uid = doc.documentID
            // ドキュメントIDからユーザーIDが判明し、ユーザーIDからユーザー情報を取得し、配列に格納
            users.append(try await UserService().fetchUser(withUid: uid))
        }
        
        return users
    }
}
