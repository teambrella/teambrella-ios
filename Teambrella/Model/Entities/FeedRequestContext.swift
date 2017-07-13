//
//  FeedRequestContext.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

struct FeedRequestContext {
    let teamID: Int
    let since: UInt64
    let offset: Int
    let limit: Int
    
}
