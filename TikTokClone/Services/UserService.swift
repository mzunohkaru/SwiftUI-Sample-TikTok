//
//  UserService.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import FirebaseAuth

enum UserError: Error {
    case unauthenticated
}

class UserService {
    // 現在のユーザー情報を取得
    func fetchCurrentUser() async throws -> User {
        // 現在のユーザーのuidが存在することを確認
        guard let uid = Auth.auth().currentUser?.uid else { throw UserError.unauthenticated }
        // 現在のユーザーのuidをドキュメントIDとして、Firestoreに保存されているデータをUser型に変換して返す
        return try await FirestoreConstants.UserCollection.document(uid).getDocument(as: User.self)
    }
    
    // 引数のuidからユーザー情報を取得
    func fetchUser(withUid uid: String) async throws -> User {
        return try await FirestoreConstants.UserCollection.document(uid).getDocument(as: User.self)
    }
}

// MARK: - Following

extension UserService {
    
    func follow(uid: String) async throws {
        // 現在のユーザーのuidが存在することを確認
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        async let _ = try FirestoreConstants
            .UserFollowingCollection(uid: currentUid)
            .document(uid) // Followする相手のuid
            .setData([:])
        
        async let _ = try FirestoreConstants
            .UserFollowerCollection(uid: uid)
            .document(currentUid)
            .setData([:])
    }
    
    func unfollow(uid: String) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        async let _ = try FirestoreConstants
            .UserFollowingCollection(uid: currentUid)
            .document(uid) // Followを外す相手のuid
            .delete()

        async let _ = try FirestoreConstants
            .UserFollowerCollection(uid: uid)
            .document(currentUid)
            .delete()
    }
    
    func checkIfUserIsFollowed(uid: String) async -> Bool {
        guard let currentUid = Auth.auth().currentUser?.uid else { return false }
        
        guard let snapshot = try? await FirestoreConstants
            .UserFollowingCollection(uid: currentUid)
            .document(uid)
            .getDocument() else { return false }
        
        // 現在のユーザーのFollowingコレクションのuser-followingサブコレクションに引数の uid が保存されている場合は、true
        return snapshot.exists
    }
}

// MARK: - User Stats

extension UserService {
    // Following, Follower, Likes の数を取得
    func fetchUserStats(uid: String) async throws -> UserStats {
        
        async let following = FirestoreConstants
            .FollowingCollection
            .document(uid)
            .collection("user-following")
            .getDocuments()
            .count
        
        async let followers = FirestoreConstants
            .FollowersCollection
            .document(uid)
            .collection("user-followers")
            .getDocuments()
            .count
        
        async let likes = FirestoreConstants
            .PostsCollection
            .whereField("ownerUid", isEqualTo: uid)
            .getDocuments(as: Post.self) // フィルタリングされたドキュメントをPost型の配列として取得
            .map({ $0.likes }) // 取得した各投稿の like の数だけを抽出し、新しい配列を作成
            .reduce(0, +) // like の数の配列を合計します。0は合計の初期値で、+は配列内の全ての要素を加算するために使用
        
        return try await .init(following: following, followers: followers, likes: likes)
    }
}
