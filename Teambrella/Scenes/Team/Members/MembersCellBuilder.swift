//
//  MembersCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 31.05.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import Kingfisher
import UIKit

struct MembersCellBuilder {
    static func populate(cell: UICollectionViewCell, with teammate: TeammateEntity) {
         if let cell = cell as? TeammateCandidateCell {
            cell.titleLabel.text = teammate.name
            if let url: URL = URL(string: service.server.avatarURLstring(for:teammate.avatar)) {
                cell.avatarView.kf.setImage(with: url)
            }
            cell.titleLabel.text = teammate.name
            let detailsText: String = "\(teammate.model), \(teammate.year)".uppercased()
            cell.detailsLabel.text = detailsText
            let dateText: String = DateProcessor().stringFromNow(minutes: -teammate.minutesRemaining).uppercased()
            cell.dateLabel.text = dateText
            cell.chartView.setupWith(remainingMinutes: teammate.minutesRemaining)
        } else if let cell = cell as? TeammateCell {
            if let url: URL = URL(string: service.server.avatarURLstring(for: teammate.avatar)) {
                cell.avatarView.kf.setImage(with: url)
            }
            guard let currency: String = service.session?.currentTeam?.currencySymbol else { return }
            
            let amountText: String = currency + "\(abs(Int(teammate.totallyPaid)))"
            cell.amountLabel.text = amountText
            let sign: String = teammate.totallyPaid > 0 ? "+" : teammate.totallyPaid < 0 ? "-" : ""
            cell.signLabel.text = sign
            let signColor: UIColor = teammate.totallyPaid > 0 ? .tealish : .lipstick
            cell.signLabel.textColor = signColor
            cell.titleLabel.text = teammate.name
            let detailsText: String = "\(teammate.model), \(teammate.year)".uppercased()
            cell.detailsLabel.text = detailsText
            cell.avatarView.badgeText = String(format: "%.1f", teammate.risk)
        }
    }
    
}
