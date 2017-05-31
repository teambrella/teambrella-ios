//
//  MembersCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit
import Kingfisher

struct MembersCellBuilder {
    static func populate(cell: UICollectionViewCell, with teammate: TeammateLike) {
         if let cell = cell as? TeammateCandidateCell {
            cell.titleLabel.text = teammate.name
            if let url = URL(string: service.server.avatarURLstring(for:teammate.avatar)) {
                cell.avatarView.kf.setImage(with: url)
            }
            cell.titleLabel.text = teammate.name
        } else if let cell = cell as? TeammateCell {
            if let url = URL(string: service.server.avatarURLstring(for: teammate.avatar)) {
                cell.avatarView.kf.setImage(with: url)
            }
            cell.amountLabel.text = "\(UInt(teammate.totallyPaid))"
            cell.titleLabel.text = teammate.name
            cell.detailsLabel.text = teammate.model
            cell.avatarView.badge?.text = String(format: "%2f", teammate.risk)
        }
    }
    
    static func construct
}
