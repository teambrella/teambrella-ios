//
//  ProxyForCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ProxyForCell: UICollectionViewCell, XIBInitableCell {

    @IBOutlet var separatorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        separatorView.backgroundColor = .paleGray
    }

}
