//
//  CommentsView.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import SwiftUI

struct CommentsView: View {
    
    @StateObject var viewModel: CommentViewModel

    // init の実行順
    // 1.  の init() が実行され、 CommentService と CommentViewModel のインスタンスが作成
    // 2. CommentViewModel の init()
    // 3. CommentService の init()
    
    init(post: Post) {
        // CommentsView の init で Service と ViewModel のインスタンスを作成することで、依存性の注入が行われる
        // CommentViewModel を通じて CommentService にアクセスすることで、データフローが一方向になる
        // CommentService -( データをフェッチ、加工 )-> CommentViewModel -( データを受け取り、UIを更新 )-> CommentsView
        let service = CommentService(post: post, userService: UserService())
        let viewModel = CommentViewModel(post: post, service: service)
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            if !viewModel.comments.isEmpty {
                Text(viewModel.commentCountText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.top, 24)
            }
            
            Divider()
            
            List {
                VStack(spacing: 24) {
                    ForEach(viewModel.comments) { comment in
                        CommentCell(comment: comment)
                    }
                }
                // リストの上部と下部のラインを非表示にする
                .listRowSeparator(.hidden)
            }
            // リストの区切り線を追加
            .listStyle(PlainListStyle())
            
            Divider()
                .padding(.bottom)
            
            HStack(spacing: 12) {
                CircularProfileImageView(user: viewModel.currentUser, size: .xSmall)
                
                CommentInputView(viewModel: viewModel)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .overlay {
            if viewModel.showEmptyView {
                ContentUnavailableView("No comments yet. Add yours now!", systemImage: "exclamationmark.bubble")
                    .foregroundStyle(.gray)
            }
        }
        .task { await viewModel.fetchComments() }
    }
}

#Preview {
    CommentsView(post: DeveloperPreview.posts[0])
}
