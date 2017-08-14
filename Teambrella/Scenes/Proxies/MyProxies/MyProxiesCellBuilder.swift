//
//  MyProxiesCellBuilder.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct MyProxiesCellBuilder {
    static func populate(cell: UICollectionViewCell, with model: ProxyCellModel) {
        if let cell = cell as? ProxyCell {
            cell.avatarView.showAvatar(string: model.avatarString)
            cell.nameLabel.text = model.name
            cell.detailsLabel.text = model.address
            model.time.map { cell.timeLabel.text = Formatter.teambrellaShort.string(from: $0) }
            
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
