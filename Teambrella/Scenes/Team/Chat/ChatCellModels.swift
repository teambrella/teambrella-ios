//
//  ChatCellModels.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.08.17.
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
    let rateText: String?
    let date: Date
    let isTemporary: Bool
    
    var totalFragmentsHeight: CGFloat { return fragmentHeights.reduce(0, +) }
    var id: String { return entity.id }
    
}

struct ChatSeparatorCellModel: ChatCellModel {
    let date: Date
    
}

struct ChatNewMessagesSeparatorModel: ChatCellModel {
    let date: Date
    let text: String = "Team.Chat.Separator.newMessages".localized
}
