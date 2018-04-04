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
    static func populate(cell: UICollectionViewCell, with teammate: TeammateListEntity) {
        let coverage = service.session?.currentTeam?.coverageType ?? .other
        if let cell = cell as? TeammateCandidateCell {
            cell.titleLabel.text = teammate.name.entire
            if let url: URL = URL(string: URLBuilder().avatarURLstring(for: teammate.avatar)) {
                cell.avatarView.kf.setImage(with: url)
            }
            cell.titleLabel.text = teammate.name.entire
            let detailsText: String = "\(teammate.model), \(teammate.year.localizedString(for: coverage))".uppercased()
            cell.detailsLabel.text = detailsText
            let dateText: String = DateProcessor().stringFromNow(minutes: -teammate.minutesRemaining)
            cell.dateLabel.text = dateText.uppercased()
            cell.chartView.setupWith(remainingMinutes: teammate.minutesRemaining)
        } else if let cell = cell as? TeammateCell {
            if let url: URL = URL(string: URLBuilder().avatarURLstring(for: teammate.avatar)) {
                cell.avatarView.kf.setImage(with: url)
            }
            let currency: String = service.currencySymbol
            let coeff = teammate.totallyPaid > 0.0 ? 0.5 : -0.5
            let amountText: String = currency + "\(abs(Int(teammate.totallyPaid + coeff)))"
            cell.amountLabel.text = amountText
            let sign: String = teammate.totallyPaid >= 0.5 ? "+" : teammate.totallyPaid <= -0.5 ? "-" : ""
            cell.signLabel.text = sign
            let signColor: UIColor = teammate.totallyPaid > 0.0 ? .tealish : .lipstick
            cell.signLabel.textColor = signColor
            cell.titleLabel.text = teammate.name.entire
            let detailsText: String = "\(teammate.model), \(teammate.year.localizedString(for: coverage))".uppercased()
            cell.detailsLabel.text = detailsText
            if let risk = teammate.risk {
                cell.avatarView.badgeText = String(format: "%.1f", risk)
            } else {
                cell.avatarView.badgeText = nil
            }
        }
    }
    
}
