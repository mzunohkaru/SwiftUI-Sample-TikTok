//
//  FeedService.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/8/23.
//

import Foundation
import FirebaseStorage
import FirebaseAuth

class FeedService {
    
    private var posts = [Post]()
    private let userService = UserService()
    
    func fetchPosts() async throws -> [Post] {
        self.posts = try await FirestoreConstants
            .PostsCollection
            .order(by: "timestamp", descending: true)
            .getDocuments(as: Post.self)
        
        // withThrowingTaskGroup(of: Void.self) : 複数の非同期タスクを並行して実行
        await withThrowingTaskGroup(of: Void.self) { group in
            for post in posts {
                // タスクをタスクグループに追加
                group.addTask { try await self.fetchPostUserData(post) }
            }
        }
        
        return posts
    }
    
    private func fetchPostUserData(_ post: Post) async throws {
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        
        let user = try await userService.fetchUser(withUid: post.ownerUid)
        // 各投稿にユーザー情報を関連付ける
        posts[index].user = user
    }

    func deletePostData(_ post: Post) async throws {
        // 投稿ユーザーのみが投稿を削除できるようにする
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        if currentUid != post.ownerUid {
            return
        }
        // Firestoreから投稿データを削除
        try await FirestoreConstants.PostsCollection.document(post.id).delete()

        // 投稿に対する「like」情報を取得するための参照
        let likesRef = FirestoreConstants.PostsCollection.document(post.id).collection("post-likes")
        // 「like」したユーザーのIDを取得
        let userLikes = try await likesRef.getDocuments().documents.map { $0.documentID }
        // 各ユーザーの「like」情報を削除
        for userId in userLikes {
            // ユーザーの「like」情報を持つサブコレクションの削除
            try await FirestoreConstants.UserCollection.document(userId).collection("user-likes").document(post.id).delete()
        }
        
        // FireStorageからサムネイル画像を削除
        try await Storage.storage().reference(withPath: "post_images/\(post.id)").delete()
        
        // FireStorageから動画データを削除
        try await Storage.storage().reference(withPath: "post_videos/\(post.id)").delete()
    }
}
