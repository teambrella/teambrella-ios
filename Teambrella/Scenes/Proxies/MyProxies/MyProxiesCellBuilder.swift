//
//  MyProxiesCellBuilder.swift
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

struct MyProxiesCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: ProxyCellModel) {
        if let cell = cell as? ProxyCell {
            cell.avatarView.showAvatar(string: model.avatarString)
            cell.nameLabel.text = model.name
            cell.detailsLabel.text = model.address.uppercased()
            //model.time.map { cell.timeLabel.text = Formatter.teambrellaShort.string(from: $0) }
            cell.timeLabel.text = String.formattedNumber(model.proxyRank ?? 1)
            
            guard let decisionsCoeff = model.decisionsCoeff,
                let discussionCoeff = model.discussionCoeff,
                let frequencyCoeff = model.frequencyCoeff else {
                    return
            }
            cell.leftBar.leftLabel.text = "Proxy.MyProxiesVC.decisions".localized
            cell.leftBar.value = CGFloat(decisionsCoeff)
            cell.middleBar.leftLabel.text = "Proxy.MyProxiesVC.discussions".localized
            cell.middleBar.value = CGFloat(discussionCoeff)
            cell.rightBar.leftLabel.text = "Proxy.MyProxiesVC.votingFreq".localized
            cell.rightBar.value = CGFloat(frequencyCoeff)
            cell.rankLabel.text = "Proxy.MyProxiesVC.proxyRank".localized
        }
    }
}
