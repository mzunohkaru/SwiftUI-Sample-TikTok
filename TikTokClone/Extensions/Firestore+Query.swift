//
//  Firestore+Query.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/10/23.
//

import Firebase

extension Query {
    // 指定されたDecodable型 （変換するモデルオブジェクト） の配列にデコードするために使用される拡張機能
    func getDocuments<T: Decodable>(as type: T.Type) async throws -> [T] {
        let snapshot = try await getDocuments()
        // Firestoreからデータを取得し、アプリ内で使用するモデルオブジェクトに変換する
        return snapshot.documents.compactMap({ try? $0.data(as: T.self) })
    }
}
