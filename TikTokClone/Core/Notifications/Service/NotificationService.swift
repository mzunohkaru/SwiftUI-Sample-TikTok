//
//  NotificationService.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import Firebase

class NotificationService {
    
    private var notifications = [Notification]()
    private let userService = UserService()
    private let postService = PostService()
    
    func fetchNotifications() async throws -> [Notification] {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }

        // 取得した通知はタイムスタンプで降順に並べかえる
        self.notifications = try await FirestoreConstants.UserNotificationCollection(uid: uid)
            .order(by: "timestamp", descending: true)
            .getDocuments(as: Notification.self)
        
        await withThrowingTaskGroup(of: Void.self) { group in
            for notification in notifications {
                // 通知の詳細情報を更新
                group.addTask { try await self.updateNotification(notification) }
            }
        }
        
        return notifications
    }
    
    func uploadNotification(toUid uid: String, type: NotificationType, post: Post? = nil) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }
        
        let ref = FirestoreConstants.UserNotificationCollection(uid: uid).document()
        // 特定のユーザーIDに対して新しい通知をアップロード
        let notification = Notification(id: ref.documentID, postId: post?.id, timestamp: Timestamp(), type: type, uid: currentUid)
        guard let data = try? Firestore.Encoder().encode(notification) else { return }
        
        ref.setData(data)
    }

    func deleteNotification(toUid uid: String, type: NotificationType, postId: String? = nil) async throws {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard uid != currentUid else { return }
        
        let snapshot = try await FirestoreConstants
            .UserNotificationCollection(uid: uid)
            .whereField("uid", isEqualTo: currentUid)
            .getDocuments()
        
        for document in snapshot.documents {
            // Notification型にデコード
            guard let notification = try? document.data(as: Notification.self) else { continue }
            // デコードされた通知のタイプが、関数に渡されたタイプと一致することを確認
            guard notification.type == type else { return }
            
            if postId != nil {
                // 通知の投稿IDと一致する場合
                guard postId == notification.postId else { return }
            }
            // ドキュメントを削除
            try await document.reference.delete()
        }
    }
    
    private func updateNotification(_ notification: Notification) async throws {
        // notifications配列内で、指定されたnotificationのIDと一致する最初の要素のインデックスを検索
        guard let indexOfNotification = notifications.firstIndex(where: { $0.id == notification.id }) else { return }
        
        // notifications配列内で、指定されたnotificationのIDと一致する最初の要素のインデックスを検索
        async let notificationUser = try userService.fetchUser(withUid: notification.uid)
        
        // 取得したユーザー情報を、notifications配列の該当する通知オブジェクトのuserプロパティに設定
        self.notifications[indexOfNotification].user = try await notificationUser

        if notification.type == .follow {
            // 取得したユーザー情報を、notifications配列の該当する通知オブジェクトのuserプロパティに設定
            async let isFollowed = userService.checkIfUserIsFollowed(uid: notification.uid)
            // notifications配列の該当する通知オブジェクトのユーザーのisFollowedプロパティに設定
            self.notifications[indexOfNotification].user?.isFollowed = await isFollowed
        }

        if let postId = notification.postId {
            // 通知に関連付けられた投稿の情報を取得し、notifications配列の該当する通知オブジェクトのpostプロパティに設定
            self.notifications[indexOfNotification].post = try? await postService.fetchPost(postId: postId)
        }
    }
}
