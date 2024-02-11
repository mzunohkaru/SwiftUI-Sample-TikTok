//
//  FeedView.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/6/23.
//

import SwiftUI
import AVKit

struct FeedView: View {
    
    // viewModelの生成の違い
    
    // ・ NotificationsView （ viewModel = NotificationsViewModel(service: NotificationService()) ）
    // NotificationsView自体がアプリの起動時に一度だけ作成され、その後は破棄されないような使われ方をするため、
    // アプリのライフサイクルに密接に関連している
    
    // ・ FeedView （ StateObject var viewModel: FeedViewModel ）
    // Viewが初期化される際にViewModelも一緒に初期化され、Viewが破棄されるまでインスタンスが保持されます
    // 投稿ごとに新しいViewModelインスタンスが必要なため、
    // Viewのライフサイクルに密接に関連している
    
    // ・ FeedCell （ @ObservedObject var viewModel: FeedCellViewModel ）
    // 外部から viewModel を受け取り、変更を監視するため
    // ライフサイクルに関連していない
    
    @Binding var player: AVPlayer
    @StateObject var viewModel: FeedViewModel
    @State private var scrollPosition: String?
    @State var isPaused = false
    
    init(player: Binding<AVPlayer>, posts: [Post] = []) {
        self._player = player
        
        let viewModel = FeedViewModel(feedService: FeedService(),
                                      postService: PostService(),
                                      posts: posts)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .topTrailing) {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach($viewModel.posts) { post in
                            FeedCell(post: post,
                                     player: player,
                                     viewModel: viewModel,
                                     isPaused: $isPaused)
                                .id(post.id) // Viewの再利用やViewの状態の追跡などに使用されます
                                .onAppear {
                                    playInitialVideoIfNecessary(forPost: post.wrappedValue)
                                }
                                
                        }
                    }
                    // ScrollView内で特定の位置までスクロールする
                    .scrollTargetLayout()
                }
                // リロード
                .refreshable {
                    Task { await viewModel.refreshFeed() }
                }
                // リロード
                Button {
                    Task { await viewModel.refreshFeed() }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .imageScale(.large)
                        .foregroundStyle(.white)
                        .shadow(radius: 4)
                        .padding(32)
                        .padding(.top, 40)
                }
            }
            .background(.black)
            // Viewが表示されたときに、ビデオの再生
            .onAppear {
                isPaused = false
                player.play()
            }
            // Viewが非表示にされた時に、ビデオを停止
            .onDisappear { 
                isPaused = false
                player.pause()
            }
            .overlay {
                // 動画のロード中
                if viewModel.isLoading {
                    ProgressView()
                } 
                // 動画データがない場合
                else if viewModel.showEmptyView {
                    ContentUnavailableView("No posts to show", systemImage: "eye.slash")
                        .foregroundStyle(.white)
                }
            }
            // スクロール位置を scrollPosition 変数にバインド
            .scrollPosition(id: $scrollPosition)
            // 1ブロックごとにスクロールできる
            .scrollTargetBehavior(.paging)
            .ignoresSafeArea()
            .navigationDestination(for: User.self, destination: { user in
                ProfileView(user: user)
            })
            // scrollPosition の値が変更されたとき
            .onChange(of: scrollPosition, { oldValue, newValue in
                // 新しい投稿のビデオを再生
                playVideoOnChangeOfScrollPosition(postId: newValue)
            })
        }
    }
    
    func playInitialVideoIfNecessary(forPost post: Post) {
        guard
            scrollPosition == nil, // スクロール位置が nil か確認
            let post = viewModel.posts.first, // viewModel.posts 配列の一番目を post に格納できるか確認
            player.currentItem == nil else { return } // プレーヤーの現在のアイテムが nil か確認
        
        // プレーヤーの現在のアイテムを置き換え
        player.replaceCurrentItem(with: AVPlayerItem(url: URL(string: post.videoUrl)!))
    }
    
    // スクロール位置が変更されたときに呼び出され、新しい投稿のビデオを再生します
    func playVideoOnChangeOfScrollPosition(postId: String?) {
        guard let currentPost = viewModel.posts.first(where: {$0.id == postId }) else { return }
        
        // プレーヤーの現在のアイテムを nil にする
        player.replaceCurrentItem(with: nil)
        
        // プレーヤーの現在のアイテムを置き換え
        let playerItem = AVPlayerItem(url: URL(string: currentPost.videoUrl)!)
        player.replaceCurrentItem(with: playerItem)
    }
}

#Preview {
    FeedView(player: .constant(AVPlayer()), posts: DeveloperPreview.posts)
}
