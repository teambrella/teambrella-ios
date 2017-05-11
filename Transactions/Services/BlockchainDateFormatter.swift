//
//  BlockchainDateFormatter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

class BlockchainDateFormatter: DateFormatter {
    override init() {
        super.init()
       setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
         dateFormat = "yyyy-MM-dd HH:mm:ss"
    }
    
}
