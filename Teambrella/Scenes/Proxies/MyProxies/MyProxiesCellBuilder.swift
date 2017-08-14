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
            
            guard let decisionsCoeff = model.decisionsCoeff,
                let discussionCoeff = model.discussionCoeff,
                let frequencyCoeff = model.frequencyCoeff else {
                    return
            }
            
            cell.leftBar.value = CGFloat(decisionsCoeff)
            cell.leftBar.leftText = ValueToTextConverter.decisionsText(from: decisionsCoeff)
            
            cell.middleBar.value = CGFloat(discussionCoeff)
            cell.leftBar.leftText = ValueToTextConverter.discussionsText(from: discussionCoeff)
            
            cell.rightBar.value = CGFloat(frequencyCoeff)
            cell.leftBar.leftText = ValueToTextConverter.frequencyText(from: frequencyCoeff)
            
        }
    }
}
