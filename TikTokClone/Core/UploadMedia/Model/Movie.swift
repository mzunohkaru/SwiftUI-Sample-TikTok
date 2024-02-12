//
//  Movie.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import AVKit
import PhotosUI
import SwiftUI

struct Movie: Transferable {

    let url: URL

    // TransferRepresentation : Movieオブジェクトをファイルとして転送するためのプロトコル
    static var transferRepresentation: some TransferRepresentation {
        // 転送するファイルのタイプが動画であることを指定
        FileRepresentation(contentType: .movie) { movie in
            // MovieオブジェクトをSentTransferredFileオブジェクトに変換
            SentTransferredFile(movie.url)
        } importing: { received in
            // 保存先のURLを生成
            let copy = URL.documentsDirectory.appending(path: "movie.mp4")
            // ファイルが既に存在するかをチェック
            if FileManager.default.fileExists(atPath: copy.path()) {
                // 削除
                try FileManager.default.removeItem(at: copy)
            }
            // 受け取ったファイルを新しい場所にコピー
            try FileManager.default.copyItem(at: received.file, to: copy)
            // 新しいMovieインスタンスを生成して返しています
            return Self.init(url: copy)
        }
    }
}

extension Movie: Hashable { }
