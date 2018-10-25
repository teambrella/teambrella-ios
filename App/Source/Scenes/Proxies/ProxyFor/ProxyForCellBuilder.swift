//
//  ProxyForCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.

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

import Foundation

struct ProxyForCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: ProxyForCellModel) {
        if let cell = cell as? ProxyForCell {
                cell.avatarView.show(model.avatar)
            cell.nameLabel.text = model.name
            if let lastVoted = model.lastVoted {
                let dateString = DateProcessor().stringInterval(from: lastVoted)
                cell.detailsLabel.text = "Proxy.ProxyForCellBuilder.lastVoted".localized + dateString
            } else {
                cell.detailsLabel.text = "Proxy.ProxyForCellBuilder.neverVoted".localized
            }
            
            guard let team = service.session?.currentTeam else { return }
            
            cell.amountLabel.text = team.currencySymbol + String(Int(model.amount))
            cell.currencyLabel.text = team.currency
        }
    }
    
}
