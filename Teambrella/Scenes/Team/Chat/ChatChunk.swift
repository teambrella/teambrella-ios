//
//  ChatChunk.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 28.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct ChatChunk: Comparable {
    let cellModels: [ChatCellModel]
    let minTime: Date
    let maxTime: Date
    var count: Int { return cellModels.count }
    
    init?(cellModels: [ChatCellModel]) {
        self.cellModels = cellModels
        let dates = cellModels.map { $0.date }
        guard let minTime = dates.min(), let maxTime = dates.max() else { return nil }
        
        self.minTime = minTime
        self.maxTime = maxTime
    }
    
    static func == (lhs: ChatChunk, rhs: ChatChunk) -> Bool {
        return lhs.minTime == rhs.minTime && lhs.maxTime == rhs.maxTime
    }
    
    static func < (lhs: ChatChunk, rhs: ChatChunk) -> Bool {
        return lhs.maxTime < rhs.maxTime
    }
    
}
