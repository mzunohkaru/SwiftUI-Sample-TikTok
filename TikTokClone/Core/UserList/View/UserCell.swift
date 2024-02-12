//
//  UserCell.swift
//  TikTokClone
//
//  Created by Stephan Dowless on 10/9/23.
//

import SwiftUI

struct UserCell: View {
    let user: User
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        HStack(spacing: 12) {
            CircularProfileImageView(user: user, size: .medium)
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(user.fullname)
                    .font(.footnote)
            }
            .foregroundStyle(.primaryText)
            
            Spacer()
        }
    }
}


#Preview {
    UserCell(user: DeveloperPreview.user)
}
