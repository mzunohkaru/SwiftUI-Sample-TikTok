//
//  MediaHelpers.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/10/23.
//

import SwiftUI
import AVKit

struct MediaHelpers {
    // 指定されたパスのビデオからサムネイル画像を生成する
    static func generateThumbnail(path: String) -> UIImage? {
        do {
            // URLの検証
            guard let url = URL(string: path) else { return nil }
            // AVURLAssetを使用して、URLからビデオのアセット (ビデオファイルの内容にアクセスするために使用) を作成
            let asset = AVURLAsset(url: url, options: nil)
            // イメージジェネレータの設定
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            // ビデオの向きを適切に調整
            imgGenerator.appliesPreferredTrackTransform = true
            // サムネイルの生成
            // CMTimeMake(value: 0, timescale: 1 : ビデオの最初のフレームで指定
            // copyCGImage : CGImage（Core Graphics Image）を生成
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            // CGImageをUIImageに変換
            return UIImage(cgImage: cgImage)
        } catch {
            print("DEBUG: Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
