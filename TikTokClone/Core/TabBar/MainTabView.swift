//
//  MainTabView.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import SwiftUI
import AVKit 
struct MainTabView: View {
    
    private let authService: AuthService
    private let user: User
    @State private var selectedTab = 0
    @State private var player = AVPlayer()
    @State private var playbackObserver: NSObjectProtocol?
    
    init(authService: AuthService, user: User) {
        self.authService = authService
        self.user = user
    }
        
    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView(player: $player)
                .toolbarBackground(.black, for: .tabBar)
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                            .environment(\.symbolVariants, selectedTab == 0 ? .fill : .none)
                        
                        Text("Home")
                    }
                }
                .onAppear { selectedTab = 0 }
                .tag(0)
            
            ExploreView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 1 ? "person.2.fill" : "person.2")
                            .environment(\.symbolVariants, selectedTab == 1 ? .fill : .none)
                        
                        Text("Friends")
                    }
                }
                .onAppear { selectedTab = 1 }
                .tag(1)
            
            MediaSelectorView(tabIndex: $selectedTab)
                .tabItem { Image(systemName: "plus") }
                .onAppear { selectedTab = 2 }
                .tag(2)
            
            NotificationsView()
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 3 ? "heart.fill" : "heart")
                            .environment(\.symbolVariants, selectedTab == 3 ? .fill : .none)
                        
                        Text("Inbox")
                    }
                }
                .onAppear { selectedTab = 3 }
                .tag(3)

            CurrentUserProfileView(authService: authService, user: user)
                .tabItem {
                    VStack {
                        Image(systemName: selectedTab == 4 ? "person.fill" : "person")
                            .environment(\.symbolVariants, selectedTab == 4 ? .fill : .none)
                        
                        Text("Profile")
                    }
                }
                .onAppear { selectedTab = 4 }
                .tag(4)
        }
        .onAppear { configurePlaybackObserver() }
        .onDisappear { removePlaybackObserver() }
        .tint(selectedTab == 0 ? .white : .primaryText)
    }
    
    // ビデオが終了したら自動的に最初から再生を再開する
    // AVPlayerの再生が終了したときに実行する
    func configurePlaybackObserver() {
        // AVPlayerItem.didPlayToEndTimeNotification (AVPlayerがアイテムの再生を終了) 通知を監視
        // 通知が受信されると、クロージャが実行
        self.playbackObserver = NotificationCenter.default.addObserver(forName: AVPlayerItem.didPlayToEndTimeNotification,
                                                                       object: nil,
                                                                       queue: .main) { _ in
            // 再生中の場合
            if player.timeControlStatus == .playing {
                // playerの再生位置をビデオの開始位置に戻す
                self.player.seek(to: CMTime.zero)
                // 再生を開始
                self.player.play()
            }
        }
    }
    
    // 不要になった監視をクリーンアップする
    // ビューが非表示になる時や、オブザーバーが不要になった時に、リソースの解放や不要なアクションの実行を避ける
    func removePlaybackObserver() {
        // playbackObserverが存在する場合
        if let playbackObserver {
            // NotificationCenterからこのオブザーバーを削除することで、
            // AVPlayerItem.didPlayToEndTimeNotification通知に対する監視が停止
            NotificationCenter.default.removeObserver(playbackObserver,
                                                      name: AVPlayerItem.didPlayToEndTimeNotification,
                                                      object: nil)
        }
    }
}

#Preview {
    MainTabView(authService: AuthService(), user: DeveloperPreview.user)
}
