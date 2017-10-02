//
//  ChatChunk.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.08.17.
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

struct ChatChunk: Comparable {
    let cellModels: [ChatCellModel]
    let minTime: Date
    let maxTime: Date
    let isTemporary: Bool
    var count: Int { return cellModels.count }
    
    init?(cellModels: [ChatCellModel], isTemporary: Bool = false) {
        self.cellModels = cellModels
        let dates = cellModels.map { $0.date }
        guard let minTime = dates.min(), let maxTime = dates.max() else { return nil }
        
        self.minTime = minTime
        self.maxTime = maxTime
        self.isTemporary = isTemporary
    }
    
    var firstTextMessage: ChatTextCellModel? {
        return cellModels.filter { $0 is ChatTextCellModel }.first as? ChatTextCellModel
    }
    
    static func == (lhs: ChatChunk, rhs: ChatChunk) -> Bool {
        return lhs.minTime == rhs.minTime && lhs.maxTime == rhs.maxTime
    }
    
    static func < (lhs: ChatChunk, rhs: ChatChunk) -> Bool {
        return lhs.maxTime < rhs.maxTime
    }
    
}
