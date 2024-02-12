//
//  FeedViewModel.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/6/23.
//

import SwiftUI

@MainActor
class FeedViewModel: ObservableObject {
    
    @Published var posts = [Post]()
    @Published var isLoading = false
    @Published var showEmptyView = false
    
    private let feedService: FeedService
    private let postService: PostService
    var isContainedInTabBar = true

    init(feedService: FeedService, postService: PostService, posts: [Post] = []) {
        self.feedService = feedService
        self.postService = postService
        self.posts = posts
        self.isContainedInTabBar = posts.isEmpty
        
        Task { await fetchPosts() }
    }
    
    func fetchPosts() async {
        isLoading = true
        
        do {
            if posts.isEmpty {
                posts = try await feedService.fetchPosts()
                posts.shuffle() // 配列の中身をシャッフルする
            }
            isLoading = false
            showEmptyView = posts.isEmpty
            await checkIfUserLikedPosts()
        } catch {
            isLoading = false
            print("DEBUG: Failed to fetch posts \(error.localizedDescription)")
        }
    }
    
    func refreshFeed() async {
        posts.removeAll()
        isLoading = true
        
        do {
            posts = try await feedService.fetchPosts()
            posts.shuffle()
            isLoading = false
        } catch {
            isLoading = false
            print("DEBUG: Failed to refresh posts with error: \(error.localizedDescription)")
        }
    }

    func deletePost(_ post: Post) async {
        do {
            try await feedService.deletePostData(post)
            // 削除された投稿を配列から削除
            posts.removeAll { $0.id == post.id }
        } catch {
            print("DEBUG: Failed to delete post with error: \(error.localizedDescription)")
        }
    }
}

// MARK: - Likes

extension FeedViewModel {
    func like(_ post: Post) async {
        // posts配列から引数で受け取ったpostのインデックスを検索
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        // 該当する投稿のdidLikeプロパティをtrueに設定
        posts[index].didLike = true
        posts[index].likes += 1
                
        do {
            try await postService.likePost(post)
        } catch {
            print("DEBUG: Failed to like post with error \(error.localizedDescription)")
            posts[index].didLike = false
            posts[index].likes -= 1
        }
    }
    
    func unlike(_ post: Post) async {
        // posts配列から引数で受け取ったpostのインデックスを検索
        guard let index = posts.firstIndex(where: { $0.id == post.id }) else { return }
        posts[index].didLike = false
        posts[index].likes -= 1
                
        do {
            try await postService.unlikePost(post)
        } catch {
            print("DEBUG: Failed to unlike post with error \(error.localizedDescription)")
            posts[index].didLike = true
            posts[index].likes += 1
        }
    }
    
    func checkIfUserLikedPosts() async {
        guard !posts.isEmpty else { return }
        var copy = posts
        
        for i in 0 ..< copy.count {
            do {
                let post = copy[i]
                // ユーザーの user-likes サブコレクションに post[i] が存在する (投稿にいいねしている) 場合は、post の didLike プロパティをtrueにする
                let didLike = try await self.postService.checkIfUserLikedPost(post)
                
                if didLike {
                    copy[i].didLike = didLike
                }
                
            } catch {
                print("DEBUG: Failed to check if user liked post")
            }
        }
        
        posts = copy
    }
}
