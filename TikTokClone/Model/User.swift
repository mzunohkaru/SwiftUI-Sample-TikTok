//
//  User.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/8/23.
//

import FirebaseAuth

struct User: Identifiable, Codable {

    let id: String
    var username: String
    let email: String
    let fullname: String
    var bio: String?
    var profileImageUrl: String?
    
    var isFollowed = false
    var stats: UserStats
    
    var isCurrentUser: Bool {
        return id == Auth.auth().currentUser?.uid
    }
    
    // Decoderプロトコルを満たすオブジェクトからUser型のインスタンスを生成するために使用されます
    init(from decoder: Decoder) throws {
        // デコーダーに対して、User構造体のプロパティと一致するキーを持つコンテナを取得する
        // User構造体内で定義された列挙型で、Userのプロパティ名 （id） を表すキー （.id） として機能します
        // JSONなどのデータからUserオブジェクトのプロパティに値を割り当てる際に、どのキーがどのプロパティに対応するかを明確にします
        // try container.decode(...) : コンテナを使用して、特定のキーに対応するデータをUser構造体の各プロパティにデコードする
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // コンテナからidキーに対応する値を取得し、それをString型としてデコードし、Userのidプロパティに割り当てます
        self.id = try container.decode(String.self, forKey: .id)
        self.username = try container.decode(String.self, forKey: .username)
        self.email = try container.decode(String.self, forKey: .email)
        self.fullname = try container.decode(String.self, forKey: .fullname)
        self.bio = try container.decodeIfPresent(String.self, forKey: .bio)
        self.profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        self.isFollowed = try container.decodeIfPresent(Bool.self, forKey: .isFollowed) ?? false 
        self.stats = try container.decodeIfPresent(UserStats.self, forKey: .stats) ?? UserStats(following: 0, followers: 0, likes: 0)
    }

    // コンテナのメリット
    // 1. 型安全性
    // キーと値の型が一致していることをコンパイル時に保証できます
    // 2. 柔軟性
    // 特定のキーに対して条件付きでデータをデコードすることが可能になります
    // プショナルなデータ構造や、バックエンドからの応答が予期せず変更された場合でも、アプリケーションが柔軟に対応できるようになります
    // 3. 明確なエラーハンドリング
    // デコードプロセス中に発生する可能性のあるエラーを、より具体的に捉えることができます
    // 4. カスタマイズ性
    // デコーダーの挙動をカスタマイズすることが可能になります
    // 例えば、日付やカスタム型など、特定の形式でエンコードされたデータをデコードする際に、カスタムデコーディングロジックを適用することができます
    
    // 処理の流れ
    // 1. decoder.container(keyedBy:)メソッドを呼び出し、デコードするデータの構造を定義します
    // CodingKeys列挙型を使用して、デコードするデータのキーを指定します
    // 2. 指定されたキーに基づいて、containerから値をデコードします。
    // このプロセスでは、decode(_:forKey:)やdecodeIfPresent(_:forKey:)などのメソッドが使用されます
    // 3. デコードされた値を使用して、インスタンスのプロパティを初期化
    
    init(id: String, username: String, email: String, fullname: String, bio: String? = nil, profileImageUrl: String? = nil) {
        self.id = id
        self.username = username
        self.email = email
        self.fullname = fullname
        self.bio = bio
        self.profileImageUrl = profileImageUrl
        self.isFollowed = false
        self.stats = .init(following: 0, followers: 0, likes: 0)
    }
}

extension User: Hashable { }

struct UserStats: Codable, Hashable {
    var following: Int
    var followers: Int
    var likes: Int
}
