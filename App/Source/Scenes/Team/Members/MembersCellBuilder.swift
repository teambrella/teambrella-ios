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
        let session = service.session
        
        let coverage = service.session?.currentTeam?.coverageType ?? .other
        let yearText = CoverageLocalizer(type: coverage).yearsString(year: teammate.year)
        if let cell = cell as? TeammateCandidateCell {
            cell.titleLabel.text = teammate.name.entire
            cell.avatarView.show(teammate.avatar)
            cell.titleLabel.text = teammate.name.entire
            cell.detailsLabel.text = "\(teammate.model), \(yearText)".uppercased()
            cell.dateLabel.text = DateProcessor().stringFromNow(minutes: -teammate.minutesRemaining).uppercased()
            cell.chartView.setupWith(remainingMinutes: teammate.minutesRemaining)
        } else if let cell = cell as? TeammateCell {
            cell.avatarView.show(teammate.avatar)
            if (teammate.coversMe > 0.0001)
            {
                let currency: String = session?.currentTeam?.currencySymbol ?? ""
                cell.amountLabel.text = String(format: "General.amountFormat".localized, Int(teammate.coversMe), currency)
                cell.signLabel.text = "+"
                cell.signLabel.textColor = .tealish
            }
            else
            {
                cell.amountLabel.text = "-"
                cell.signLabel.text = ""
            }
            cell.titleLabel.text = teammate.name.entire
            let detailsText: String = "\(teammate.model), \(yearText)".uppercased()
            cell.detailsLabel.text = detailsText
            if let risk = teammate.risk {
                cell.avatarView.badgeText = String(format: "%.1f", risk)
            } else {
                cell.avatarView.badgeText = nil
            }
        }
    }
    
}
