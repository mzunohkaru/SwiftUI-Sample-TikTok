//
//  EditProfileViewModel.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/10/23.
//

import SwiftUI
import Firebase
import FirebaseStorage

class EditProfileViewModel: ObservableObject {
    
    func uploadProfileImage(_ uiImage: UIImage, currentUid: String) async -> String? {
        do {
            try await deleteUserProfileImageStorage(currentUid: currentUid)
            async let imageUrl = ImageUploader.uploadImage(image: uiImage, type: .profile(path: currentUid))
            try await updateUserProfileImage(withImageUrl: try await imageUrl)
            return try await imageUrl
        } catch {
            print("DEBUG: Failed to update image with error: \(error.localizedDescription)")
            return nil 
        }
    }
    
    func updateUserProfileImage(withImageUrl imageUrl: String?) async throws {
        guard let imageUrl = imageUrl else { return }
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        try await FirestoreConstants.UserCollection.document(currentUid).updateData([
            "profileImageUrl": imageUrl
        ])
    }
    
    private func deleteUserProfileImageStorage(currentUid: String) async throws {
        // FireStorageから動画データを削除
        let ref = Storage.storage().reference(withPath: "profile_images/\(currentUid)")
        ref.delete { error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
            } else {
                print("DEBUG: File does not exist or has been successfully deleted")
            }
        }
    }
}
