//
//  FeedCell.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/8/23.
//

import SwiftUI
import AVKit

struct FeedCell: View {
    
    @Binding var post: Post
    var player: AVPlayer
    @ObservedObject var viewModel: FeedViewModel
    @State private var expandCaption = false
    @State private var showComments = false
    @Binding var isPaused: Bool
        
    private var didLike: Bool { return post.didLike }
    
    var body: some View {
        ZStack {
            VideoPlayer(player: player)
                .containerRelativeFrame([.horizontal, .vertical])
            
            if isPaused {
                Image(systemName: "play")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.white)
            }
                    
            VStack {
                Spacer()
                
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(LinearGradient(colors: [.clear, .black.opacity(0.15)],
                                             startPoint: .top,
                                             endPoint: .bottom))
                    
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(post.user?.username ?? "")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                            
                            Text(post.caption)
                                .lineLimit(expandCaption ? 50 : 2)
                            
                        }
                        .onTapGesture { withAnimation(.snappy) { expandCaption.toggle() } }
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .padding()
                        
                        Spacer()
                        
                        VStack(spacing: 28) {
                            NavigationLink(value: post.user) {
                                ZStack(alignment: .bottom) {
                                    CircularProfileImageView(user: post.user, size: .medium)
                                    
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundStyle(.pink)
                                        .background(.white)
                                        .clipShape(Circle())
                                        .offset(y: 8)
                                }
                            }
                            
                            Button {
                                handleLikeTapped()
                            } label: {
                                FeedCellActionButtonView(imageName: "heart.fill", 
                                                         value: post.likes,
                                                         tintColor: didLike ? .red : .white)
                            }
                            
                            Button {
                                player.pause()
                                showComments.toggle()
                            } label: {
                                FeedCellActionButtonView(imageName: "ellipsis.bubble.fill", value: post.commentCount)
                            }
                            
                            Button {
                                Task { await viewModel.deletePost(post) }
                            } label: {
                                FeedCellActionButtonView(imageName: "bookmark.fill",
                                                         value: post.saveCount,
                                                         height: 28,
                                                         width: 22,
                                                         tintColor: .white)
                            }
                            
                            Button {
                                
                            } label: {
                                FeedCellActionButtonView(imageName: "arrowshape.turn.up.right.fill",
                                                         value: post.shareCount)
                            }
                        }
                        .padding()
                    }
                    .padding(.bottom, viewModel.isContainedInTabBar ? 80 : 12)
                }
            }
            .sheet(isPresented: $showComments) {
                CommentsView(post: post)
                    .presentationDetents([.height(UIScreen.main.bounds.height * 0.65)])
                    .presentationDragIndicator(.visible)
            }
            .onTapGesture {
                switch player.timeControlStatus {
                case .paused:
                    isPaused = false
                    player.play()
                    // stallする可能性がある場合は、再生が一時停止した上で stall し、可能性が最小化した段階で自動的に再生が再開
                case .waitingToPlayAtSpecifiedRate:
                    break
                case .playing:
                    isPaused = true
                    player.pause()
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func handleLikeTapped() {
        Task { didLike ? await viewModel.unlike(post) : await viewModel.like(post) }
    }
}

#Preview {
    FeedCell(
        post: .constant(DeveloperPreview.posts[0]),
        player: AVPlayer(),
             viewModel: FeedViewModel(
                feedService: FeedService(),
                postService: PostService()
             ),
        isPaused: .constant(false)
    )
}
