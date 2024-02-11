//
//  ContentViewModel.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import Combine
import Firebase

@MainActor
class ContentViewModel: ObservableObject {
    
    // session情報を ContentViewModel と AuthService で分離させる （シングルトンで管理しない） メリット
    // 1. 責任の分離
    // AuthServiceは認証に関連するロジックを担当
    // ContentViewModelはビューの状態管理を担当
    // 2. テストの容易さ
    // それぞれを個別にモックしてテストすることができる
    // 3. 依存関係の削減
    // クラス間の依存関係が減る
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthService
    private let userService: UserService
    
    init(authService: AuthService, userService: UserService) {
        self.authService = authService
        self.userService = userService
        
        authService.updateUserSession()
        
        setupSubscribers()
    }
    
    private func setupSubscribers() {
        // userSessionの値が変更を購読する
        // .sink : Publisherからの出力を受け取り、与えられたクロージャを実行します。このクロージャは、userSessionの新しい値（sessionとして参照される）を引数として受け取ります
        authService.$userSession.sink { [weak self] session in
            self?.userSession = session
            self?.fetchCurrentUser()
        }.store(in: &cancellables)
    }
    
    func fetchCurrentUser() {
        guard userSession != nil else { return }
        Task { self.currentUser = try await userService.fetchCurrentUser() }
    }
}
