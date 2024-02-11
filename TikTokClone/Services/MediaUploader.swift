//
//  ImageUploader.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import UIKit
import Firebase
import FirebaseStorage

enum UploadType {
    case profile(path: String)
    case post(path: String)
    
    var filePath: StorageReference {
        // let filename = NSUUID().uuidString
        switch self {
        case .profile(let path):
//            return Storage.storage().reference(withPath: "/profile_images/\(filename)")
            return Storage.storage().reference(withPath: "/profile_images/\(path)")
        case .post(let path):
//            return Storage.storage().reference(withPath: "/post_images/\(filename)")
            return Storage.storage().reference(withPath: "/post_images/\(path)")
        }
    }
}

struct ImageUploader {
    static func uploadImage(image: UIImage, type: UploadType) async throws -> String? {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return nil }
        let ref = type.filePath
        
        do {
            // 画像データをアップロードする
            let _ = try await ref.putDataAsync(imageData)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            print("DEBUG: Failed to upload image \(error.localizedDescription)")
            return nil
        }
    }
}

import UIKit
import Firebase

struct VideoUploader {
    
    static func uploadVideoToStorage(withUrl url: URL, postId: String) async throws -> String? {
//        let filename = NSUUID().uuidString
//        let ref = Storage.storage().reference(withPath: "/post_videos/").child(filename)
        
        let urlString = url.absoluteString
        let ref = Storage.storage().reference(withPath: "/post_videos/").child(postId)
        
        let metadata = StorageMetadata()
        // メタデータに動画という情報を設定する
        metadata.contentType = "video/quicktime"
        
        do {
            let data = try Data(contentsOf: url)
            let _ = try await ref.putDataAsync(data, metadata: metadata)
            let url = try await ref.downloadURL()
            return url.absoluteString
        } catch {
            print("DEBUG: Failed to upload video with error: \(error.localizedDescription)")
            throw error
        }
    }
}
