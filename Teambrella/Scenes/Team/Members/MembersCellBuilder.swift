//
//  MembersCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Kingfisher
import UIKit

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
            cell.amountLabel.text = "\(abs(Int(teammate.totallyPaid)))"
            cell.signLabel.text = teammate.totallyPaid > 0 ? "+" : teammate.totallyPaid < 0 ? "-" : ""
            cell.signLabel.textColor = teammate.totallyPaid > 0 ? .tealish : .lipstick
            cell.titleLabel.text = teammate.name
            cell.detailsLabel.text = teammate.model
            cell.avatarView.badge?.text = String(format: "%2f", teammate.risk)
        }
    }
    
}
