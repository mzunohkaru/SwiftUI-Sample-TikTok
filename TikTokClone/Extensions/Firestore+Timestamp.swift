//
//  Firestore+Timestamp.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/11/23.
//

import Firebase

extension Timestamp {
    func timestampString() -> String {
        // 日付や時間の成分（年、月、日、時間など）をフォーマットするために使用
        let formatter = DateComponentsFormatter()
        // フォーマッタが表示する時間の単位を設定
        formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
        
        // フォーマッタが表示する最大の時間単位の数を1に設定
        // 例えば「1日」や「2時間」のように、最も大きな単位のみを表示する
        formatter.maximumUnitCount = 1

        // 時間の単位のスタイルを省略形に設定
        // 例えば、「秒」は「s」、「分」は「m」と表示する
        formatter.unitsStyle = .abbreviated
        // Timestamp を Date に変換したものから現在の日付 (Date()) までの時間を計算し、設定したフォーマットで文字列として返しま
        return formatter.string(from: self.dateValue(), to: Date()) ?? ""
    }
}
