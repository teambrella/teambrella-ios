//
//  ProxyForHeader.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ProxyForHeader: UICollectionReusableView, XIBInitableCell {
    @IBOutlet var containerView: UICollectionReusableView!
    @IBOutlet var headerLabel: BlockHeaderLabel!
    @IBOutlet var amountLabel: AmountLabel!
    @IBOutlet var currencyLabel: CurrencyLabel!
    @IBOutlet var detailsLabel: StatusSubtitleLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        CellDecorator.shadow(for: containerView)
        CellDecorator.roundedEdges(for: containerView)
    }
    
}
