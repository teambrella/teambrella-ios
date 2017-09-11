//
//  SocketCommand.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.09.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

enum SocketCommand: Int {
    case auth           = 0
    case newPost        = 1
    case deletePost     = 2
    case meTyping       = 3
    case newClaim       = 4
    case privateMessage = 5
    case walletFunded   = 6
    case newMessages    = 7
    
    case theyTyping     = 13
}
