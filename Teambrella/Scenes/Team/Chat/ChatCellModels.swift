//
//  ChatCellModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol ChatCellModel {
    var date: Date { get }
}

struct ChatTextCellModel: ChatCellModel {
    let entity: ChatEntity
    let fragments: [ChatFragment]
    let fragmentHeights: [CGFloat]
    
    let isMy: Bool
    let userName: String
    let userAvatar: String
    let voteRate: Double
    let date: Date
    
    var totalFragmentsHeight: CGFloat { return fragmentHeights.reduce(0, +) }
    var id: String { return entity.id }
    
}
