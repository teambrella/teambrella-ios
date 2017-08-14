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
            cell.avatarView.kf.setImage(with: URL(string: model.avatarString))
            cell.nameLabel.text = model.name
            cell.detailsLabel.text = model.address
            model.time.map { cell.timeLabel.text = Formatter.teambrellaShort.string(from: $0) }
            
            guard let des = model.decisionsCoeff,
                let dis = model.discussionCoeff,
                let freq = model.frequencyCoeff else {
                    return
            }
            
            cell.leftBar.value = CGFloat(des)
            cell.leftBar.leftText = ValueToTextConverter.decisionsText(from: des)
            
            cell.middleBar.value = CGFloat(dis)
            cell.leftBar.leftText = ValueToTextConverter.discussionsText(from: dis)
            
            cell.rightBar.value = CGFloat(freq)
            cell.leftBar.leftText = ValueToTextConverter.frequencyText(from: freq)
            
        }
    }
}
