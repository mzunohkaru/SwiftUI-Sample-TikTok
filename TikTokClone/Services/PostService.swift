//
//  PostService.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/10/23.
//

import Firebase

class PostService {
    
    // 指定された postId を持つ投稿を取得
    func fetchPost(postId: String) async throws -> Post {
        return try await FirestoreConstants
            .PostsCollection
            .document(postId)
            //  Firestore に保存されているデータを取得するとき、そのデータはデフォルトで辞書型（[String: Any]）などの汎用的な形式で返されます
            .getDocument(as: Post.self) // Post 型のオブジェクトにデコード（変換）する
    }
    
    // 指定されたユーザーが所有する投稿をすべて取得
    func fetchUserPosts(user: User) async throws -> [Post] {
        var posts = try await FirestoreConstants
            .PostsCollection
            // ownerUid フィールドがユーザーの ID と等しいドキュメントを検索
            .whereField("ownerUid", isEqualTo: user.id)
            .getDocuments(as: Post.self)
        
        for i in 0 ..< posts.count {
            // 投稿の user 情報を設定
            posts[i].user = user
        }
        
        return posts
    }
}

// MARK: - Likes

extension PostService {
    // 指定された投稿に「いいね」を追加
    func likePost(_ post: Post) async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        async let _ = try FirestoreConstants.PostsCollection.document(post.id).collection("post-likes").document(uid).setData([:])
        async let _ = try FirestoreConstants.PostsCollection.document(post.id).updateData(["likes": post.likes + 1])
        async let _ = try FirestoreConstants.UserCollection.document(uid).collection("user-likes").document(post.id).setData([:])
        
        NotificationManager.shared.uploadLikeNotification(toUid: post.ownerUid, post: post)
    }
    // 指定された投稿の「いいね」を削除
    func unlikePost(_ post: Post) async throws {
        guard post.likes > 0 else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        async let _ = try FirestoreConstants.PostsCollection.document(post.id).collection("post-likes").document(uid).delete()
        async let _ = try FirestoreConstants.UserCollection.document(uid).collection("user-likes").document(post.id).delete()
        async let _ = try FirestoreConstants.PostsCollection.document(post.id).updateData(["likes": post.likes - 1])
        
        async let _ = NotificationManager.shared.deleteNotification(toUid: post.ownerUid, type: .like)
    }
    // 指定された投稿に対して、現在のユーザーが「いいね」をしているかどうかを確認
    func checkIfUserLikedPost(_ post: Post) async throws -> Bool {
        guard let uid = Auth.auth().currentUser?.uid else { return false }
                
        let snapshot = try await FirestoreConstants.UserCollection.document(uid).collection("user-likes").document(post.id).getDocument()
        return snapshot.exists
    }
}
