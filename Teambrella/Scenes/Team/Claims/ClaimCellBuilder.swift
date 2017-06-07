//
//  ClaimCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 07.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

struct ClaimCellBuilder {
    static func populate(cell: UICollectionViewCell, with claim: EnhancedClaimEntity) {
        if let cell = cell as? ImageGalleryCell {
            let imageURLStrings = claim.largePhotos.flatMap { service.server.urlString(string: $0) }
            print(imageURLStrings)
            cell.setupGallery(with: imageURLStrings)
            cell.avatarView.kf.setImage(with: URL(string: service.server.avatarURLstring(for: claim.avatar)))
            cell.titleLabel.text = "Claim \(claim.topicID)"
            cell.textLabel.text = claim.originalPostText
            cell.unreadCountLabel.text = "\(claim.unreadCount)"
            cell.timeLabel.text = "\(claim.minutesinceLastPost) MIN AGO"
        }
    }

}
